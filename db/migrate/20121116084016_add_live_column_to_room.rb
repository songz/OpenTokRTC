class AddLiveColumnToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :live, :boolean
  end
end
