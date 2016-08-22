class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :vote
      t.integer :room_id
      t.boolean :moderator
    end
  end
end
