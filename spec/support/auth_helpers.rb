# frozen_string_literal: true

module AuthHelpers
  def create_user!(email: "admin@example.com", password: "password123")
    User.create!(
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  def auth_headers_for(user)
    user.create_new_auth_token
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
