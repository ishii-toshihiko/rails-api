# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contacts::SendInquiryService do
  let(:env) do
    {
      "RESEND_API_KEY" => "re_test_key",
      "CONTACT_TO_EMAIL" => "owner@example.com",
      "CONTACT_FROM_EMAIL" => "Works IT <onboarding@resend.dev>"
    }
  end

  around do |example|
    original = env.keys.index_with { |key| ENV[key] }
    env.each { |key, value| ENV[key] = value }
    example.run
  ensure
    original.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  it "posts to Resend and returns success" do
    http = instance_double(Net::HTTP)
    response = Net::HTTPOK.new("1.1", "200", "OK")
    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:request) do |request|
      body = JSON.parse(request.body)
      expect(request["Authorization"]).to eq("Bearer re_test_key")
      expect(body["to"]).to eq([ "owner@example.com" ])
      expect(body["from"]).to eq("Works IT <onboarding@resend.dev>")
      expect(body["reply_to"]).to eq("visitor@example.com")
      expect(body["text"]).not_to include("re_test_key")
      response
    end

    result = described_class.call(
      name: "Visitor",
      email: "visitor@example.com",
      message: "hello"
    )

    expect(result.success?).to be(true)
  end

  it "returns failure when configuration is missing" do
    ENV.delete("RESEND_API_KEY")

    result = described_class.call(
      name: "Visitor",
      email: "visitor@example.com",
      message: "hello"
    )

    expect(result.success?).to be(false)
  end
end
