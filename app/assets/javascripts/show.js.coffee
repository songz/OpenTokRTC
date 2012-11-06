myId = ""
position = ""

Pusher.channel_auth_transport = 'jsonp'
Pusher.channel_auth_endpoint = 'http://tbrtcdemo.herokuapp.com/pusher/auth'
pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe("presence-#{sessionId}")

channel.bind 'pusher:subscription_succeeded', ->
  myId = channel.members.me.id
  count = channel.members.count
  console.log("you are user number: "+count)
  console.log("Your user ID is: "+myId)

#TB.setLogLevel(TB.DEBUG)



# OpenTok Video
api_key = '21393201'
publisher = TB.initPublisher( api_key, "myPublisher", {width:260, height:190} )
sessionId = $('#info').attr('tbSession')
token = $("#info").attr('tbToken')

subscribeStreams = (streams) ->
  console.log streams.length
  for stream in streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    divId = "stream#{stream.connection.connectionId}"
    newDiv = $("<div />", {id:divId})
    element$ = $(".subscriberContainer:first")
    element$.append newDiv
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
    name = stream.name
    console.log name

session = TB.initSession( sessionId )

session.addEventListener 'streamCreated', streamCreatedHandler
session.addEventListener 'sessionConnected', sessionConnectedHandler
session.addEventListener 'streamDestroyed', destroyedStreams

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

