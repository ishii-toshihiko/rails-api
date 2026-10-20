# frozen_string_literal: true

module V1
  class ContactsController < ApplicationController
    # お問合せ（公開）。To は CONTACT_TO_EMAIL 固定。本文はログに出さない。
    def create
      unless Contacts::RateLimiter.allow?(request.remote_ip)
        return render json: { error: "Too many requests" }, status: :too_many_requests
      end

      form = Contacts::InquiryForm.new(inquiry_params)

      if form.honeypot_filled?
        Rails.logger.info("contacts: honeypot rejected")
        return render json: { ok: true }, status: :ok
      end

      unless form.valid?
        return render json: { error: "Invalid request" }, status: :unprocessable_entity
      end

      result = Contacts::SendInquiryService.call(
        name: form.name,
        email: form.email,
        message: form.message
      )

      if result.success?
        render json: { ok: true }, status: :ok
      else
        render json: { error: "Failed to send" }, status: :bad_gateway
      end
    end

    private

    def inquiry_params
      params.permit(:name, :email, :message, :website)
    end
  end
end
