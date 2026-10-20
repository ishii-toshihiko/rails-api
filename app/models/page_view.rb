# frozen_string_literal: true

class PageView < ApplicationRecord
  validates :path, presence: true, uniqueness: true
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  def self.hit!(raw_path)
    path = normalize_path(raw_path)

    page_view = find_or_create_by!(path: path) do |record|
      record.count = 0
    end
    page_view.with_lock do
      page_view.increment!(:count)
    end
    page_view
  end

  def self.normalize_path(raw_path)
    path = raw_path.to_s.strip
    path = "/" if path.blank?
    path = "/#{path}" unless path.start_with?("/")
    path
  end
  private_class_method :normalize_path
end
