$('#create_topic').on 'click', ->
  $('#createRoom').modal('show')

$('#joinRoom').on 'show', ->
  # One reason why I don't always like coffeescript:
  # window?? I'd like some freedom with my scopes.
  window.publisher = TB.initPublisher apiKey, 'joinRoomPublisher', {width:400, height:300}

$('#joinRoom').on 'hide', ->
  window.publisher.destroy()

$('#createRoom').on 'show', ->
  window.publisher = TB.initPublisher apiKey, 'createRoomPublisher', {width:400, height:300}

$('#createRoom').on 'hide', ->
  window.publisher.destroy()

# Focus Input when modal loads
$("#createRoom").on 'shown', ->
  $("#room_title").focus()
$("#joinRoom").on 'shown', ->
  $("#client_name").focus()

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

# TODO: When new members are updated via pusher, the corresponding room member and pictures should be updated.
# TODO: When new room is created, new view should be created
pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe(applicationChannel)

channel.bind 'room-destroyed', (roomData)->
  room = rooms.get(roomData.id)
  rooms.remove(room)

# BackboneJS
class Room extends Backbone.Model
  initialize: ->
    # subscribe to Pusher presence channel for this room
    channel = pusher.subscribe(@get("channel_name"))

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
    $('#joinRoom').modal('show')

class RoomsView extends Backbone.View
  el: "#roomList"
  initialize: =>
    @collection.on 'reset', @render
    @collection.on 'remove', @render
    @collection.fetch()
  render: =>
    @$el.empty()
    for model in @collection.models
      if model.get('clients').length >= 4
        model.set {open:false}
      else
        model.set {open:true}
      view = new RoomView {model:model}
      @$el.append view.render().el

rooms = new Rooms()
roomsView = new RoomsView collection:rooms




