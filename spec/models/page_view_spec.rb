# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageView do
  describe ".hit!" do
    it "normalizes blank path to root" do
      page_view = described_class.hit!("")
      expect(page_view.path).to eq("/")
      expect(page_view.count).to eq(1)
    end
  end
end
