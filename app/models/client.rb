class Client < ActiveRecord::Base
  attr_accessible :flag, :imgdata, :point, :room_id, :name, :filter, :cid
  belongs_to :room
	after_create :notify_creation
	before_destroy :notify_destruction

  def goLive
    self.update_attributes( live:true )
  end

	protected

	def notify_creation
    # When a client is created, the public channel for the whole app will be
		# notified
    #Pusher[Webrtc::Application.config.application_channel].trigger('client-created', {id:self.id})
	end

	def notify_destruction
    # When a client is destroyed, the public channel for the whole app will be
		# notified
    Pusher[Webrtc::Application.config.application_channel].trigger('client-destroyed', {id:self.id, room_id:self.room_id})
	end
end
