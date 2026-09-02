require "rails_helper"

RSpec.describe "Health" do
  describe "GET /" do
    it "returns ok" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("status" => "ok")
    end
  end
end
