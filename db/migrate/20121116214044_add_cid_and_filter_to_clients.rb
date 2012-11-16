class AddCidAndFilterToClients < ActiveRecord::Migration
  def change
    add_column :clients, :cid, :string
    add_column :clients, :filter, :string
  end
end
