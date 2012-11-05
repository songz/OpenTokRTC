class Client < ActiveRecord::Base
  attr_accessible :flag, :imgdata, :point, :room_id, :name

  belongs_to :room
end
