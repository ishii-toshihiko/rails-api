# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Skills" do
  let!(:skill) { Skill.create!(category: "soft", item: "Ruby", term: 5) }
  let(:valid_params) { { category: "soft", item: "TypeScript", term: 3 } }

  describe "GET /v1/skills" do
    it "returns skills without authentication" do
      get "/v1/skills"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => skill.id,
        "category" => "soft",
        "item" => "Ruby",
        "term" => 5
      )
    end
  end

  describe "GET /v1/skills/:id" do
    it "returns a skill without authentication" do
      get "/v1/skills/#{skill.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("id" => skill.id, "item" => "Ruby")
    end

    it "returns 404 when missing" do
      get "/v1/skills/0"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Skill not found")
    end
  end

  describe "POST /v1/skills" do
    it "creates a skill when authenticated" do
      headers = auth_headers_for(create_user!)

      expect {
        post "/v1/skills", params: valid_params, headers: headers, as: :json
      }.to change(Skill, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "category" => "soft",
        "item" => "TypeScript",
        "term" => 3
      )
    end

    it "returns 401 without authentication" do
      post "/v1/skills", params: valid_params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(Skill.where(item: "TypeScript")).not_to exist
    end

    it "returns 422 when validation fails" do
      headers = auth_headers_for(create_user!)

      post "/v1/skills",
           params: valid_params.merge(category: "unknown"),
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq("error" => "Invalid request")
    end
  end

  describe "PATCH /v1/skills/:id" do
    it "updates a skill when authenticated" do
      headers = auth_headers_for(create_user!)

      patch "/v1/skills/#{skill.id}",
            params: { category: "soft", item: "Ruby", term: 8 },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("term" => 8)
      expect(skill.reload.term).to eq(8)
    end

    it "returns 401 without authentication" do
      patch "/v1/skills/#{skill.id}",
            params: { category: "soft", item: "Ruby", term: 8 },
            as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(skill.reload.term).to eq(5)
    end
  end

  describe "DELETE /v1/skills/:id" do
    it "deletes a skill when authenticated" do
      headers = auth_headers_for(create_user!)

      expect {
        delete "/v1/skills/#{skill.id}", headers: headers, as: :json
      }.to change(Skill, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 401 without authentication" do
      expect {
        delete "/v1/skills/#{skill.id}", as: :json
      }.not_to change(Skill, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
