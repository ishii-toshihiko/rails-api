# frozen_string_literal: true

module Skills
  module Owner
    module_function

    def email
      ENV.fetch("SKILLS_OWNER_EMAIL", "").to_s.strip.downcase
    end

    def owner?(user)
      return false if user.blank? || email.blank?

      user.email.to_s.strip.downcase == email
    end
  end
end
