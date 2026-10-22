# frozen_string_literal: true

module Skills
  class PublishDraftsService
    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      raise ForbiddenError, "Only the skills owner can publish" unless Owner.owner?(@user)

      ActiveRecord::Base.transaction do
        Skill.delete_all
        @user.skill_drafts.order(:id).find_each do |draft|
          Skill.create!(
            category: draft.category,
            item: draft.item,
            term: draft.term
          )
        end
      end

      Skill.order(:id)
    end

    class ForbiddenError < StandardError; end
  end
end
