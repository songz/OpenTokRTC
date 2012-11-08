class PagesController < ApplicationController
  def auth
    ap session[:client_id]
    ap session[:client_name]
    ap session[:client_room_id]
    @client = Client.find session[:client_id]
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      user_id: @client.id,
      user_info: {
        name: @client.name,
        room_id: @client.room_id,
        imgdata: @client.imgdata
      }
    })
    render :json=> response.to_json, :callback => params[:callback]
  end

  def hooks
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      webhook.events.each do |event|
        ap event["name"]
        ap event
        case event["name"]
        when 'member_added'
          ap "member_added"
        when 'member_removed'
          ap "member_removed"
        when 'channel_occupied'
          ap "channel_occupied"
        when 'channel_vacated'
          ap "channel_vacated"

          # Channel is empty, time to remove the Room
          room = Room.find_by_channel_name event.data.name
          room.destroy
        end
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end

  def token
    token = OTSDK.generateToken( :session_id=>params[:session], :role=>OpenTok::RoleConstants::MODERATOR )
    render :json=>{token:token}
  end
end
