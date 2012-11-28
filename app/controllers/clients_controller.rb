class ClientsController < ApplicationController

  # GET /rooms
  # GET /rooms.json
  def index
    if params.has_key?("room")
      @clients = Client.where(:room_id => params[:room])
    else
      @clients = Client.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
    end
  end

  def show
    @client = Client.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client }
    end
  end

  # POST /rooms
  # POST /rooms.json
  def create
    ap params
    ap "CREATE CLIENT"
    @room = Room.find(params[:room])
    if @room.clients.length < 4
      #client = @room.clients.build(params[:client])
      client = @room.clients.create(params[:client])
      @room.goLive
      session[:client_id] = client.id
      session[:client_name] = client.name
      session[:client_room_id] = client.room_id
      render json: client, status: :created, location: client
    else
      render json: {status:"failed"}
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.json
  def update
    client = Client.find(params[:id])
    client.cid = params[:cid]
    client.filter = params[:filter]

    respond_to do |format|
      if client.save!
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
    @room = Room.find(params[:room])
    client = @room.clients.find(params[:id])
    client.destroy

    respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end
end
