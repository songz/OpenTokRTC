# OpenTok Code:
apiKey = "21393201"
publisher = TB.initPublisher apiKey, 'myPublisher', {width:400, height:300}

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
#
# TODO: When new members are updated via pusher, the corresponding room member and pictures should be updated.
#
# TODO: When new room is created, new view should be created

pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe('newroom')



# BackboneJS
class Room extends Backbone.Model
  initialize: ->
    # subscribe to Pusher channel for this room to find out when Clients are
    # created, updated, or destroyed
    channel = pusher.subscribe(@get("channel_name"))
    backpusher = new Backpusher()

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
      view = new RoomView {model:model}
      @$el.append view.render().el

rooms = new Rooms()
roomsView = new RoomsView collection:rooms



