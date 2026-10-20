# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PageViews" do
  describe "POST /v1/page_views" do
    it "increments and returns the count" do
      expect do
        post "/v1/page_views", params: { path: "/" }, as: :json
      end.to change(PageView, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("path" => "/", "count" => 1)

      post "/v1/page_views", params: { path: "/" }, as: :json
      expect(response.parsed_body).to include("path" => "/", "count" => 2)
    end
  end
end
