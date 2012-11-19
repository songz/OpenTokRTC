class Client < ActiveRecord::Base
  attr_accessible :flag, :imgdata, :point, :room_id, :name, :filter, :cid
  belongs_to :room
	after_create :notify_creation
	before_destroy :notify_destruction

	protected

	def notify_creation
    # When a client is created, the public channel for the whole app will be
		# notified
    Pusher[Webrtc::Application.config.application_channel].trigger('client-created', self.attributes)
	end

	def notify_destruction
    # When a client is destroyed, the public channel for the whole app will be
		# notified
    Pusher[Webrtc::Application.config.application_channel].trigger('client-destroyed', self.attributes)
	end
end
