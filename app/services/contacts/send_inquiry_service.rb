# frozen_string_literal: true

require "net/http"
require "json"

module Contacts
  class SendInquiryService
    RESEND_URL = URI("https://api.resend.com/emails")

    Result = Struct.new(:success?, keyword_init: true)

    def self.call(name:, email:, message:)
      new(name: name, email: email, message: message).call
    end

    def initialize(name:, email:, message:)
      @name = name
      @email = email
      @message = message
    end

    def call
      api_key = ENV.fetch("RESEND_API_KEY")
      to_email = ENV.fetch("CONTACT_TO_EMAIL")
      from_email = ENV.fetch("CONTACT_FROM_EMAIL")

      response = post_email!(api_key: api_key, to_email: to_email, from_email: from_email)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("contacts: resend request failed status=#{response.code}")
        return Result.new(success?: false)
      end

      Rails.logger.info("contacts: inquiry accepted")
      Result.new(success?: true)
    rescue KeyError => e
      Rails.logger.error("contacts: missing configuration key=#{e.key}")
      Result.new(success?: false)
    rescue StandardError
      Rails.logger.error("contacts: unexpected send failure")
      Result.new(success?: false)
    end

    private

    attr_reader :name, :email, :message

    def post_email!(api_key:, to_email:, from_email:)
      http = Net::HTTP.new(RESEND_URL.host, RESEND_URL.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(RESEND_URL)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"
      request.body = {
        from: from_email,
        to: [ to_email ],
        reply_to: email,
        subject: "Portfolio contact from #{name}",
        text: body_text
      }.to_json

      http.request(request)
    end

    def body_text
      <<~TEXT
        Name: #{name}
        Email: #{email}

        Message:
        #{message}
      TEXT
    end
  end
end
