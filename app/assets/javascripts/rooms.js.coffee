$('.create-room-btn').on 'click', ->
  $('.create-room').modal('show')

# Focus Input when modal loads
$(".create-room").on 'shown', ->
  $("#room_title").focus()

# When new members are updated via pusher, the corresponding room member and pictures should be updated.
# When new room is created, new view should be created
clientTemplate = Handlebars.compile( $("#client-template").html() )
pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe(applicationChannel)
channel.bind 'room-created', (data)->
  console.log "room-created"
  console.log data
  roomsView.addRoom( data )
channel.bind 'room-destroyed', (data)->
  console.log "room-destroyed"
  console.log data
  $("[data-room=#{data.id}]").remove()
channel.bind 'client-destroyed', (data)->
  console.log "client-destroyed"
  console.log data
  $("[client=#{data.id}]").remove()
channel.bind 'client-created', (data)->
  console.log "client-created"
  console.log data
  console.log $("[data-room=#{data.room_id}] #user_preview").append( clientTemplate(data) )

# BackboneJS
class Room extends Backbone.Model

class Rooms extends Backbone.Collection
  model: Room
  url: "/rooms"

class RoomView extends Backbone.View
  tagName: "li",
  className: "room",
  template: Handlebars.compile( $("#room-template").html() )
  events:
    "click" : "roomSelected"
  render: ->
    if @model.get("clients").length < 4
      @$el.addClass("open")
      @model.set("open", true)
    @$el.attr("data-room", @model.get("id"))
    @$el.html @template(@model.toJSON())
    return @
  roomSelected: ->
    if @model.get('open')
      window.location = "/rooms/#{@model.get('id')}"

class RoomsView extends Backbone.View
  el: ".room-list"
  initialize: =>
    @collection.on 'reset', @render
    @collection.on 'remove', @render
    @collection.fetch()
  render: =>
    @$el.empty()
    for model in @collection.models
      view = new RoomView {model:model}
      @$el.append view.render().el
  addRoom: (data) ->
    model = new Room( data )
    view = new RoomView {model:model}
    @$el.append view.render().el

rooms = new Rooms()
roomsView = new RoomsView collection:rooms

