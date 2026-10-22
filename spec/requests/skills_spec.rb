# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Skills" do
  let!(:skill) { Skill.create!(category: "soft", item: "Ruby", term: 5) }

  describe "GET /v1/skills" do
    it "returns published skills without authentication" do
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
    it "returns a published skill without authentication" do
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
    it "is not available (writes go through skill_drafts)" do
      headers = auth_headers_for(create_user!)

      post "/v1/skills",
           params: { category: "soft", item: "TypeScript", term: 3 },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
