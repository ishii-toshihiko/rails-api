# frozen_string_literal: true

class CreateSkillDrafts < ActiveRecord::Migration[7.2]
  def change
    create_table :skill_drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category, null: false
      t.string :item, null: false
      t.integer :term, null: false

      t.timestamps
    end

    add_index :skill_drafts, [ :user_id, :item ]
  end
end
