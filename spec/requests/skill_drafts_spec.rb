# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SkillDrafts" do
  let!(:published) { Skill.create!(category: "soft", item: "Ruby", term: 5) }
  let(:valid_params) { { category: "soft", item: "TypeScript", term: 3 } }
  let(:owner_email) { "owner@example.com" }
  let(:owner) { create_user!(email: owner_email) }
  let(:guest) { create_user!(email: "guest@example.com") }

  around do |example|
    previous = ENV["SKILLS_OWNER_EMAIL"]
    ENV["SKILLS_OWNER_EMAIL"] = owner_email
    example.run
  ensure
    ENV["SKILLS_OWNER_EMAIL"] = previous
  end

  describe "GET /v1/skill_drafts" do
    it "returns 401 without authentication" do
      get "/v1/skill_drafts"

      expect(response).to have_http_status(:unauthorized)
    end

    it "seeds drafts from published skills when empty" do
      headers = auth_headers_for(guest)

      get "/v1/skill_drafts", headers: headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["can_publish"]).to be(false)
      expect(body["drafts"].size).to eq(1)
      expect(body["drafts"].first).to include("item" => "Ruby", "term" => 5)
      expect(guest.skill_drafts.count).to eq(1)
    end

    it "marks can_publish for the owner" do
      headers = auth_headers_for(owner)

      get "/v1/skill_drafts", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["can_publish"]).to be(true)
    end
  end

  describe "POST /v1/skill_drafts" do
    it "creates a draft for the current user only" do
      headers = auth_headers_for(guest)

      expect {
        post "/v1/skill_drafts", params: valid_params, headers: headers, as: :json
      }.to change { guest.skill_drafts.count }.by(1)
        .and change(Skill, :count).by(0)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include("item" => "TypeScript")
    end

    it "does not affect another user's drafts" do
      owner_headers = auth_headers_for(owner)
      get "/v1/skill_drafts", headers: owner_headers
      expect(owner.skill_drafts.count).to eq(1)

      guest_headers = auth_headers_for(guest)
      post "/v1/skill_drafts", params: valid_params, headers: guest_headers, as: :json

      expect(owner.skill_drafts.reload.map(&:item)).to eq([ "Ruby" ])
      expect(guest.skill_drafts.reload.map(&:item)).to include("TypeScript")
    end
  end

  describe "PATCH /v1/skill_drafts/:id" do
    it "updates only the current user's draft" do
      headers = auth_headers_for(guest)
      get "/v1/skill_drafts", headers: headers
      draft_id = guest.skill_drafts.first.id

      patch "/v1/skill_drafts/#{draft_id}",
            params: { category: "soft", item: "Ruby", term: 8 },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(guest.skill_drafts.find(draft_id).term).to eq(8)
      expect(published.reload.term).to eq(5)
    end

    it "returns 404 for another user's draft id" do
      owner_headers = auth_headers_for(owner)
      get "/v1/skill_drafts", headers: owner_headers
      owner_draft_id = owner.skill_drafts.first.id

      guest_headers = auth_headers_for(guest)
      patch "/v1/skill_drafts/#{owner_draft_id}",
            params: { category: "soft", item: "Ruby", term: 9 },
            headers: guest_headers,
            as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /v1/skill_drafts/:id" do
    it "deletes the current user's draft without touching published skills" do
      headers = auth_headers_for(guest)
      get "/v1/skill_drafts", headers: headers
      draft_id = guest.skill_drafts.first.id

      expect {
        delete "/v1/skill_drafts/#{draft_id}", headers: headers, as: :json
      }.to change { guest.skill_drafts.count }.by(-1)
        .and change(Skill, :count).by(0)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /v1/skill_drafts/reset" do
    it "replaces drafts with the published skills" do
      headers = auth_headers_for(guest)
      get "/v1/skill_drafts", headers: headers
      guest.skill_drafts.first.update!(term: 99)
      guest.skill_drafts.create!(category: "soft", item: "Temp", term: 1)

      post "/v1/skill_drafts/reset", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      items = response.parsed_body["drafts"].map { |d| [ d["item"], d["term"] ] }
      expect(items).to eq([ [ "Ruby", 5 ] ])
    end
  end

  describe "POST /v1/skill_drafts/publish" do
    it "publishes owner drafts to skills" do
      headers = auth_headers_for(owner)
      get "/v1/skill_drafts", headers: headers
      owner.skill_drafts.first.update!(term: 12)
      owner.skill_drafts.create!(category: "heard", item: "FPGA", term: 2)

      post "/v1/skill_drafts/publish", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["ok"]).to be(true)
      expect(Skill.order(:id).pluck(:item, :term)).to contain_exactly(
        [ "Ruby", 12 ],
        [ "FPGA", 2 ]
      )
    end

    it "forbids non-owners from publishing" do
      headers = auth_headers_for(guest)
      get "/v1/skill_drafts", headers: headers
      guest.skill_drafts.first.update!(term: 99)

      post "/v1/skill_drafts/publish", headers: headers, as: :json

      expect(response).to have_http_status(:forbidden)
      expect(published.reload.term).to eq(5)
    end
  end
end
