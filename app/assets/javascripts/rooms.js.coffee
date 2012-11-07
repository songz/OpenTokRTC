# OpenTok Code:
apiKey = "21393201"
publisher = ""

# Activate Publisher when Modal is shown
$("#joinRoom").on 'shown', ->
  if publisher == ""
    publisher = TB.initPublisher apiKey, 'myPublisher', {width:400, height:300}
  $("#client_name").focus()

# Focus Input when modal loads
$("#createRoom").on 'shown', ->
  $("#room_title").focus()

# When user submits form, take a picture
$("#new_client").submit ->
  imgData = publisher.getImgData()
  if imgData?
    $("#client_imgdata").val( imgData )
    publisher.destroy()
    return
  else
    alert "Please allow chrome to access your camera"
    return false

# BackboneJS
class Room extends Backbone.Model

class Rooms extends Backbone.Collection
  model: Room
  url: "/rooms"

class RoomView extends Backbone.View
  template: Handlebars.compile( $("#room-template").html() )
  events:
    "click" : "roomSelected"
  render: ->
    @$el.html @template(@model.toJSON())
    return @
  roomSelected: ->
    $('#joinRoom [name="client[room_id]"]').val(@model.get "id")

class RoomsView extends Backbone.View
  el: "#roomList"
  initialize: ->
    @collection.on 'reset', @render
    @collection.fetch()
  render: (data) =>
    @$el.empty()
    for model in data.models
      if model.get('clients').length >= 4
        model.set {open:false}
      else
        model.set {open:true}
      view = new RoomView {model:model}
      @$el.append view.render().el
  addRoom: (data) ->
    roomTemplate = Handlebars.compile( $("#room-template").html() )
    @$el.append roomTemplate( data )
  destroyRoom: (rid) ->
    @.$("[room=#{rid}]").fadeOut ->
      $(@).remove()
  addClient: (data) ->
    cid = data.client_id
    rid = data.room_id
    clientTemplate = Handlebars.compile( $('#client-template').html() )
    @.$("[room=#{rid}] #user_preview").append( clientTemplate(data) )
    if @.$("[room=#{rid}] #user_preview li").length >= 4
      @.$("[room=#{rid}] .liveSign img").attr( 'src', "/img/greylight.png" )
      @.$("[room=#{rid}] .liveSign .roomStatus").text("Closed")
  destroyClient: (data) ->
    cid = data.client_id
    rid = data.room_id
    @.$("[room=#{rid}] .liveSign img").attr( 'src', "/img/greenlight.png" )
    @.$("[room=#{rid}] .liveSign .roomStatus").text("Open")

rooms = new Rooms()
window.roomsView = new RoomsView collection:rooms


# TODO: When new members are updated via pusher, the corresponding room member and pictures should be updated.
#
# TODO: When new room is created, new view should be created
source = $("#room-template").html()
roomTemplate = Handlebars.compile(source)

pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe('roomstatus')

channel.bind 'addRoom', (data) ->
  console.log "add room"
  console.log data
  roomsView.addRoom( data )
channel.bind 'destroyRoom', (data) ->
  console.log "destroy room"
  console.log data
  roomsView.destroyRoom( data.room_id )
channel.bind 'addClient', (data) ->
  console.log "addClient"
  console.log data
  roomsView.addClient( data )
channel.bind 'destroyClient', (data) ->
  roomsView.destroyClient( data )
  console.log data
