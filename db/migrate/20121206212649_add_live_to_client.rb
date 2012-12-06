class AddLiveToClient < ActiveRecord::Migration
  def change
    add_column :clients, :live, :boolean
  end
end
