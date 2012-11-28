class Room < ActiveRecord::Base
  attr_accessible :client_id, :description, :feature, :session_id, :title, :clients_attributes, :live
  has_many :clients, :dependent => :destroy
  accepts_nested_attributes_for :clients
  before_destroy :notify_destruction

  def self.allLive
    # this replaces Room.all function. We only want to show rooms with > 1 person in it
    self.where(:live=>true)
  end

  def goLive
    # When a room is created, the public channel for the whole app will be notified
    if not self.live
      Pusher[Webrtc::Application.config.application_channel].trigger('room-created', self.attributes )
      self.update_attributes( live:true )
    end
  end

  def self.find_by_channel_name(channel_name="")
    session_id = channel_name.gsub(/^presence-/, "")
    self.find_by :session_id => session_id
  end

  def channel_name
    "presence-#{self.session_id}"
  end

  def as_json(options=nil)
    super({
      :methods => [:channel_name],
      :include => :clients
    }.merge(options))
  end

  protected
  def notify_destruction
    # When a room is destroyed, the public channel for the whole app will be notified
    Pusher[Webrtc::Application.config.application_channel].trigger('room-destroyed', self.attributes)
  end

end
