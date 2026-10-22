# frozen_string_literal: true

module Skills
  class SyncDraftsFromPublishedService
    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        @user.skill_drafts.delete_all
        Skill.order(:id).find_each do |skill|
          @user.skill_drafts.create!(
            category: skill.category,
            item: skill.item,
            term: skill.term
          )
        end
      end

      @user.skill_drafts.order(:id)
    end
  end
end
