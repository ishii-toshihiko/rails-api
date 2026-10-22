# frozen_string_literal: true

module Skills
  class SkillForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    CATEGORIES = %w[soft heard].freeze

    attribute :category, :string
    attribute :item, :string
    attribute :term, :integer

    validates :category, presence: true, inclusion: { in: CATEGORIES }
    validates :item, presence: true, length: { maximum: 100 }
    validates :term, presence: true,
                     numericality: {
                       only_integer: true,
                       greater_than_or_equal_to: 0,
                       less_than_or_equal_to: 50
                     }

    def to_skill_attributes
      {
        category: category,
        item: item.to_s.strip,
        term: term
      }
    end
  end
end
