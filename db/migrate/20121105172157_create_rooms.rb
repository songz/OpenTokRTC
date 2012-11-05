class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :session_id
      t.string :title
      t.text :description
      t.boolean :feature
      t.integer :client_id

      t.timestamps
    end
  end
end
