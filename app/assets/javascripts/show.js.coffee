myId = ""
position = ""

# Pusher Initialization
Pusher.channel_auth_transport = 'jsonp'
Pusher.channel_auth_endpoint = '/pusher/auth'
pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = ""

# OpenTok Video Initializers
api_key = '21393201'
publisher = TB.initPublisher( api_key, "myPublisher", {width:260, height:190} )
sessionId = $('#info').attr('tbSession')
token = $("#info").attr('tbToken')
session = ""

# templates
window.messageTemplate = Handlebars.compile( $("#messageTemplate").html() )
window.userStreamTemplate = Handlebars.compile( $("#userStreamTemplate").html() )

# TokBox Code
removeStream = (cid) ->
  element$ = $(".stream#{cid}")
  element$.addClass "subscriberContainer"
  element$.removeClass ".stream#{cid}"

subscribeStreams = (streams) ->
  for stream in streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    divId = "stream#{stream.connection.connectionId}"
    element$ = $(".subscriberContainer:first")
    myCode = window.userStreamTemplate( {id:divId} )
    element$.html myCode
    console.log element$.find('.flagUser')
    element$.find('.flagUser').click ->
      streamConnection = $(this).attr('streamConnection')
      inappropriate = confirm("Is this user being inappropriate?")
      if inappropriate
        $(".#{streamConnection} video").css("-webkit-filter", "Blur(15px)")
        channel.trigger 'client-inappropriate', { streamConnection: streamConnection }
        alert( "Thankyou. User will be removed")
    element$.addClass("stream#{stream.connection.connectionId}")
    element$.removeClass("subscriberContainer")
    session.subscribe( stream, divId , {width:260, height:190} )

sessionConnectedHandler = (event) ->
  if event.streams >= 4
    window.location = "/"
  subscribeStreams(event.streams)
  session.publish( publisher )

streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)

destroyedStreams = (e) ->
  for stream in e.streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    removeStream( stream.connection.connectionId )

# Start Execution - connect to pusher and session
startExecution = ->
  channel = pusher.subscribe("presence-#{sessionId}")
  channel.bind 'pusher:subscription_succeeded', ->
    myId = channel.members.me.id
    window.userName = channel.members.me.info.name
    count = channel.members.count
    if count.length >= 4
      window.location = "/"
    $(".filterOption").click ->
      $(".filterOption").removeClass("optionSelected")
      prop = $(this).text()
      applyFilter( prop, "#myPublisher video" )
      channel.trigger 'client-filter', { cid: session.connection.connectionId, filter: prop }
      $(this).addClass("optionSelected")

  channel.bind 'client-filter', (data) ->
    console.log data
    applyFilter( data.filter, ".stream#{data.cid} video" )
  channel.bind 'client-inappropriate', (data) ->
    if "stream#{session.connection.connectionId}" == data.streamConnection
      window.location = "/"

# Chat Room
dataRef = new Firebase("https://song.firebaseio.com/tbwebrtc/#{sessionId}")
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

# Submit a room and registering user
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
  $('#clientInfoContainer').remove()
  $('#createClientOverlay').fadeOut 'slow', ->
    $('#statusBar').slideDown('slow')
  session = TB.initSession( sessionId )
  session.addEventListener 'streamCreated', streamCreatedHandler
  session.addEventListener 'sessionConnected', sessionConnectedHandler
  session.addEventListener 'streamDestroyed', destroyedStreams
  session.connect( api_key, token )
  $.post "/clients", {client:client, room:room_id}, (data)->
    if data.id > 0
      $('#statusBar').slideUp('slow')
      $("#userImageSrc").attr('src', data.imgdata)
      startExecution()
    else
      window.location = "/"
 
applyFilter = (prop, selector) ->
  switch prop
    when "Blur"
      $(selector).css("-webkit-filter", "Blur(15px)")
    when "Sepia"
      $(selector).css("-webkit-filter", "sepia(100%)")
    when "Grayscale"
      $(selector).css("-webkit-filter", "grayscale(100%)")
    when "Invert"
      $(selector).css("-webkit-filter", "invert(100%)")
    when "None"
      $(selector).css("-webkit-filter", "")

#focus on name Field
$("#clientName").focus()

$(".subscriber_stream_content").mouseenter ->
  $(this).find('.flagUser').show()
  console.log("HOVERRRR!")
$(".subscriber_stream_content").mouseleave ->
  $(this).find('.flagUser').hide()
  console.log("HOVERRRR!")

# remove for testing
#startExecution()
#$('#clientInfoContainer').fadeOut('fast')
#session = TB.initSession( sessionId )
#session.addEventListener 'streamCreated', streamCreatedHandler
#session.addEventListener 'sessionConnected', sessionConnectedHandler
#session.addEventListener 'streamDestroyed', destroyedStreams
#session.connect( api_key, token )
