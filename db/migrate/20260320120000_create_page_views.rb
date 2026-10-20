# frozen_string_literal: true

class CreatePageViews < ActiveRecord::Migration[7.2]
  def change
    create_table :page_views do |t|
      t.string :path, null: false
      t.bigint :count, null: false, default: 0

      t.timestamps
    end

    add_index :page_views, :path, unique: true
  end
end
