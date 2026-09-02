require "rails_helper"

RSpec.describe Skill do
  it "is valid with attributes" do
    skill = Skill.new(category: "soft", item: "Ruby", term: 1)
    expect(skill).to be_valid
  end

  it "persists to the database" do
    skill = Skill.create!(category: "soft", item: "Ruby", term: 1)
    expect(skill).to be_persisted
  end
end
