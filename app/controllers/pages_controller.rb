class PagesController < ApplicationController
  def auth
    printa session[:client_id]
    printa session[:client_name]
    printa session[:client_room_id]
    @client = Client.find session[:client_id]
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      :user_id => @client.id
    })
    render :json=> response.to_json, :callback => params[:callback]
  end

  def hooks
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      webhook.events.each do |event|
        printa event["name"]
        case event["name"]
        when 'channel_occupied'
          puts "Channel occupied: #{event["channel"]}"
        when 'channel_vacated'
          printa "EMPTY CHANNEL!!!!"
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
