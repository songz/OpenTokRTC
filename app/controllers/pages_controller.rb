class PagesController < ApplicationController
  protect_from_forgery :except => :auth # stop rails CSRF protection for this action

  def auth
    ap "PUSHER AUTH"
    ap "PUSHER AUTH"
    ap "PUSHER AUTH"
    ap "PUSHER AUTH"
    ap "PUSHER AUTH"
    ap "PUSHER AUTH"
    ap session[:client_id]
    ap session[:client_name]
    ap session[:client_room_id]
    @client = Client.find session[:client_id]
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      user_id: @client.id,
      user_info: {
        name: @client.name,
        room_id: @client.room_id,
      }
    })
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
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
          ap "client is added to room"
        when 'channel_occupied'
          p "Channel occupied"
        when 'channel_vacated'
          p "channel is empty"
          session_id = event['channel'].split('presence-').last
          for e in Room.where( session_id: session_id )
            e.destroy() # Necessary because sometimes client not always destroyed (multiple created)
          end
        when 'member_removed'
          client = Client.find(event['user_id'])
          client.destroy()
          ap "client destroyed"
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
