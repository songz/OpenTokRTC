class Room < ActiveRecord::Base
  attr_accessible :client_id, :description, :feature, :session_id, :title

  has_many :clients
end
