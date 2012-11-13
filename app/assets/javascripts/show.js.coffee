myId = ""
position = ""

# Pusher Initialization
Pusher.channel_auth_transport = 'jsonp'
Pusher.channel_auth_endpoint = '/pusher/auth'
pusher = new Pusher('9b96f0dc2bd6198af8ed')

# OpenTok Video Initializers
#TB.setLogLevel(TB.DEBUG)
api_key = '21393201'
publisher = TB.initPublisher( api_key, "myPublisher", {width:260, height:190} )
sessionId = $('#info').attr('tbSession')
token = $("#info").attr('tbToken')
session = TB.initSession( sessionId )

subscribeStreams = (streams) ->
  for stream in streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    divId = "stream#{stream.connection.connectionId}"
    newDiv = $("<div />", {id:divId})
    element$ = $(".subscriberContainer:first")
    element$.append newDiv
    element$.addClass("stream#{stream.connection.connectionId}")
    element$.removeClass("subscriberContainer")
    session.subscribe( stream, divId , {width:259, height: 189} )

sessionConnectedHandler = (event) ->
  subscribeStreams(event.streams)
  session.publish( publisher )

streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)

destroyedStreams = (e) ->
  for stream in e.streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    element$ = $(".stream#{stream.connection.connectionId}")
    element$.addClass "subscriberContainer"
    element$.removeClass ".stream#{stream.connection.connectionId}"

session.addEventListener 'streamCreated', streamCreatedHandler
session.addEventListener 'sessionConnected', sessionConnectedHandler
session.addEventListener 'streamDestroyed', destroyedStreams

# Start Execution
startExecution = ->
  channel = pusher.subscribe("presence-#{sessionId}")
  channel.bind 'pusher:subscription_succeeded', ->
    myId = channel.members.me.id
    count = channel.members.count
  session.connect( api_key, token )

# Chat Box
dataRef = new Firebase("https://song.firebaseio.com/tbwebrtc/#{sessionId}")

window.messageTemplate = Handlebars.compile( $("#message-template").html() )

$('#messageInput').keydown (e) ->
  if (e.keyCode == 13)
    text = $('#messageInput').val()
    dataRef.push({name: window.userName, text: text})
    $('#messageInput').val('')

dataRef.on 'child_added', (snapshot) ->
  message = window.messageTemplate( snapshot.val() )
  $("#displayChat").append message
  $('#displayChat')[0].scrollTop = $('#displayChat')[0].scrollHeight

$('#chatInput input').focus ->
  $('.icon-comments-alt').css('color','#C40A68')
$('#chatInput input').focusout ->
  $('.icon-comments-alt').css('color','#8D8F8F')

$('#submitClientName').click ->
  name = $("#clientName").val()
  imgdata = publisher.getImgData()
  room_id = $('#info').attr('room_id')
  if (not imgdata?) or imgdata.length < 10
    alert("Please allow chrome to access your device camera")
    return
  client =
    imgdata:imgdata
    name:name
  $.post "/clients", {client:client, room:room_id}, (data)->
    $('#clientInfoContainer h1').text('Loading...')
    $('#submitClientName').fadeOut('fast')
    if data.id > 0
      $('#clientInfoContainer').fadeOut('fast')
      $('#createClientOverlay').fadeOut('slow')
      startExecution()
    else
      $('#clientInfoContainer h1').text('What is your name?')
      $('#submitClientName').fadeIn('fast')
