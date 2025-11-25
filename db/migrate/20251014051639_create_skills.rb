class CreateSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :skills do |t|
      t.string :category
      t.string :item
      t.integer :term

      t.timestamps
    end
  end
end
