# frozen_string_literal: true

class SkillDraft < ApplicationRecord
  belongs_to :user

  validates :category, presence: true
  validates :item, presence: true
  validates :term, presence: true,
                   numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
