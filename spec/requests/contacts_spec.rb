# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contacts" do
  let(:valid_params) do
    {
      name: "山田太郎",
      email: "visitor@example.com",
      message: "お問合せです",
      website: ""
    }
  end

  before do
    Contacts::RateLimiter.reset!
    allow(Contacts::SendInquiryService).to receive(:call)
      .and_return(Contacts::SendInquiryService::Result.new(success?: true))
  end

  describe "POST /v1/contacts" do
    it "accepts a valid inquiry" do
      post "/v1/contacts", params: valid_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("ok" => true)
      expect(Contacts::SendInquiryService).to have_received(:call).with(
        name: "山田太郎",
        email: "visitor@example.com",
        message: "お問合せです"
      )
    end

    it "returns 422 when validation fails" do
      post "/v1/contacts", params: valid_params.merge(email: "not-an-email"), as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq("error" => "Invalid request")
      expect(Contacts::SendInquiryService).not_to have_received(:call)
    end

    it "returns ok without sending when honeypot is filled" do
      post "/v1/contacts", params: valid_params.merge(website: "https://spam.example"), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("ok" => true)
      expect(Contacts::SendInquiryService).not_to have_received(:call)
    end

    it "returns 429 when the IP exceeds the rate limit" do
      Contacts::RateLimiter::LIMIT.times do
        post "/v1/contacts", params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
      end

      post "/v1/contacts", params: valid_params, as: :json

      expect(response).to have_http_status(:too_many_requests)
      expect(response.parsed_body).to eq("error" => "Too many requests")
    end

    it "returns 502 with a generic message when send fails" do
      allow(Contacts::SendInquiryService).to receive(:call)
        .and_return(Contacts::SendInquiryService::Result.new(success?: false))

      post "/v1/contacts", params: valid_params, as: :json

      expect(response).to have_http_status(:bad_gateway)
      expect(response.parsed_body).to eq("error" => "Failed to send")
    end
  end
end
