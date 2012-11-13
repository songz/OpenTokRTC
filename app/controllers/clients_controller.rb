class ClientsController < ApplicationController

  # GET /rooms
  # GET /rooms.json
  def index
    @clients = Client.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
    end
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.find(params[:room])
    client = @room.clients.build(params[:client])
    if client.save!
      session[:client_id] = client.id
      session[:client_name] = client.name
      session[:client_room_id] = client.room_id

      # Notify everyone else interested via Pusher
      #Pusher[@room.channel_name].trigger('created', client.attributes, request.headers["X-Pusher-Socket-ID"])
      render json: client, status: :created, location: client
    else
      render json: {status:"failed"}
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.json
  def update
    client = @rooms.clients.find(params[:id])

    respond_to do |format|
      if client.update_attributes(params[:client])

        # Notify everyone else interested via Pusher
        Pusher[@room.channel_name].trigger('updated', client.attributes, request.headers["X-Pusher-Socket-ID"])

        format.html { redirect_to client, notice: 'Client was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    client = @room.clients.find(params[:id])
    client.destroy

    respond_to do |format|
      # Notify everyone else interested via Pusher
      Pusher[@room.channel_name].trigger('destroyed', client.attributes, request.headers["X-Pusher-Socket-ID"])

      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end
end
