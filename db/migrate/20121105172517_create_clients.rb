class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :room_id
      t.string :imgdata
      t.integer :flag
      t.integer :point

      t.timestamps
    end
  end
end
