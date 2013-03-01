class RoomsController < ApplicationController
  # GET /rooms
  # GET /rooms.json
  def index
    @room = Room.new
    @rooms = Room.allLive
    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: @rooms.to_json( include: :clients ) }
      format.json { render "index" }
    end
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @room = Room.find(params[:id])
    @client = @room.clients.build
    @token = OTSDK.generateToken( :session_id=>@room.session_id, :role=>OpenTok::RoleConstants::MODERATOR )

    respond_to do |format|
      format.html # show.html.erb
      format.json { render "show" }
      #format.json { render json: @room.to_json( include: :clients ) }
    end
  end

  # GET /rooms/new
  # GET /rooms/new.json
  def new
    @room = Room.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @room }
    end
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(params[:room])
    @room.session_id = OTSDK.createSession( request.ip ).session_id

    respond_to do |format|
      if @room.save
        format.html { 
          redirect_to @room, notice: 'Room was successfully created.' 
        }
        format.json { render json: @room, status: :created, location: @room }
      else
        format.html { render action: "new" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.json
  def update
    @room = Room.find(params[:id])

    respond_to do |format|
      if @room.update_attributes(params[:room])
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end
end
