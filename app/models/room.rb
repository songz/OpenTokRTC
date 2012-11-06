class Room < ActiveRecord::Base
  attr_accessible :client_id, :description, :feature, :session_id, :title

  has_many :clients

	before_create :create_token

	def self.find_by_token(token)
		self.includes(:clients).where(:token => token).limit(1).first
	end

	def create_token
		self.token = strip_for_channel_name(ActiveSupport::SecureRandom.base64(8))
	end

	def channel_name
		@channel_name ||= "list-#{Rails.env}-#{strip_for_channel_name(self.token)}"
	end

	def strip_for_channel_name(str)
		str.gsub("/", "").gsub("+", "").gsub(/=+$/, "")
	end
end
