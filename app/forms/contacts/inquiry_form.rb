# frozen_string_literal: true

module Contacts
  class InquiryForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :email, :string
    attribute :message, :string
    attribute :website, :string

    validates :name, presence: true, length: { maximum: 100 }
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :message, presence: true, length: { maximum: 2000 }

    def honeypot_filled?
      website.to_s.strip.present?
    end
  end
end
