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
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        session[:client_id] = @client.id
        session[:client_name] = @client.name
        format.html { redirect_to @client.room, notice: 'Room was successfully created.' }
        format.json { render json: @client, status: :created, location: @client }
      else
        format.html { render action: "new" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.json
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:room])
        format.html { redirect_to @client, notice: 'Room was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end
end
