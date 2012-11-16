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
  roomsView.addRoom( data )
channel.bind 'room-destroyed', (data)->
  console.log "room-destroyed"
  roomsView.removeRoom( data )
channel.bind 'client-destroyed', (data)->
  console.log "client-destroyed"
  roomsView.removeClient( data )
channel.bind 'client-created', (data)->
  console.log "client-created"
  roomsView.addClient( data )

# BackboneJS
class Room extends Backbone.Model

class Rooms extends Backbone.Collection
  model: Room
  url: "/rooms"

class RoomView extends Backbone.View
  tagName: "li"
  className: "room"
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
  removeView: ->
    @$el.remove()
  addClient: (data) ->
    @$(".userPreview ul").append( clientTemplate(data) )
    clients = @model.get("clients")
    clients.push(data)
    @model.set {clients: clients}
    if clients.length >= 4
      @model.set({open:false})
      @$el.addClass("open")
      @$el.attr("data-room", @model.get("id"))
      @$el.html @template(@model.toJSON())
  removeClient: (data) ->
    reRender = false
    clients = @model.get("clients")
    if clients.length >= 4
      reRender = true
    index = -1
    for e in clients
      if e.id == data.id
        index = clients.indexOf(e)
    if index>=0
      clients.splice(index,1)
      @model.set {clients: clients}
      @$("[client=#{data.id}]").remove()
    if reRender
      @model.set({open:true})
      @$el.addClass("open")
      @$el.attr("data-room", @model.get("id"))
      @$el.html @template(@model.toJSON())

class RoomsView extends Backbone.View
  el: ".room-list"
  initialize: =>
    @collection.on 'reset', @render
    @collection.on 'remove', @render
    @collection.fetch()
    @views = {}
  render: =>
    @$el.empty()
    for model in @collection.models
      view = new RoomView {model:model}
      @views[model.get('id')] = view
      @$el.append view.render().el
  addRoom: (data) ->
    model = new Room( data )
    view = new RoomView {model:model}
    @views[models.get('id')] = view
    @$el.append view.render().el
  removeRoom: (data) ->
    console.log @views
    @views[data.id].removeView()
    delete @views[data.id]
    console.log @views
  addClient: (data) ->
    if @views[data.room_id]?
      @views[data.room_id].addClient( data )
  removeClient: (data) ->
    @views[data.room_id].removeClient( data )

rooms = new Rooms()
roomsView = new RoomsView collection:rooms

