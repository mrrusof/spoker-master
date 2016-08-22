class CreateStories < ActiveRecord::Migration[5.0]
  def change
    create_table :stories do |t|
      t.string :name
      t.integer :estimate
      t.integer :room_id
      t.timestamps
    end
  end
end
