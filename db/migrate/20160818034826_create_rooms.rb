class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :visible_votes
      t.integer :estimate
      t.string :story_name
      t.timestamps
    end
  end
end
