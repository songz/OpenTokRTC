myId = ""
position = ""
window.clientsData = {}

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
  applyClassFilter( null, ".stream#{data.cid}" )
  element$ = $(".stream#{cid}")
  element$.empty()
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
        session.forceDisconnect( streamConnection.split("stream")[1] )
        channel.trigger 'client-inappropriate', { streamConnection: streamConnection }
        alert( "Thank you. User will be removed")
    element$.addClass("stream#{stream.connection.connectionId}")
    element$.removeClass("subscriberContainer")
    session.subscribe( stream, divId , {width:260, height:190} )
    # Apply any existing filters to the video element
    if window.clientsData[stream.connection.connectionId]?
      console.log "STREAM RECEIVED... PPLAYING FILTER"
      newClient = window.clientsData[stream.connection.connectionId]
      if newClient.filter?
        applyClassFilter(newClient.filter, ".stream#{newClient.cid}")
        #applyFilter(newClient.filter, ".stream#{newClient.cid} video")

sessionConnectedHandler = (event) ->
  if event.streams >= 4
    window.location = "/"
  startExecution()
  $('#statusBar').slideUp('slow')
  subscribeStreams(event.streams)
  # save connection id to server
  window.myClient.cid = session.connection.connectionId
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
      prop = $(this).attr('value')
      applyClassFilter( prop, "#myPublisher" )
      channel.trigger 'client-filter', { cid: session.connection.connectionId, filter: prop }
      window.myClient.filter = prop
      updateClientData()
      $(this).addClass("optionSelected")

  channel.bind 'client-filter', (data) ->
    console.log data
    #applyFilter( data.filter, ".stream#{data.cid} video" )
    applyClassFilter( data.filter, ".stream#{data.cid}" )
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
  $('#clientInfoContainer').remove()
  $('#createClientOverlay').fadeOut 'slow', ->
    $('#statusBar').slideDown('slow')
  session = TB.initSession( sessionId )
  session.addEventListener 'streamCreated', streamCreatedHandler
  session.addEventListener 'sessionConnected', sessionConnectedHandler
  session.addEventListener 'streamDestroyed', destroyedStreams

  # Resize image via canvas, then upload base64
  canvas = document.getElementById( 'myPictureCanvas' )
  ctx = canvas.getContext("2d")
  image = new Image()
  image.src = "data:image/png;base64,#{imgdata}"
  image.onload = ->
    #drawImage( src, s_offsetX, s_offsetY, s_width, s_height, ... )
    ctx.drawImage(image, 80, 0, 480, 480, 0, 0, 100, 100)
    dataURL = canvas.toDataURL("image/png")
    client =
      imgdata:dataURL
      name:name
    $.post "/clients", {client:client, room:room_id}, (data)->
      if data.id > 0
        window.myClient = {id:data.id}
        $('#statusBar').slideUp('slow')
        $("#userImageSrc").attr('src', data.imgdata)
        # read all the client data
        getClientData(room_id)
        session.connect( api_key, token )
      else
        alert("Sorry, the room appears to be full")
        window.location = "/"
 
applyClassFilter = (prop, selector) ->
  $(selector).removeClass( "Blur Sepia Grayscale Invert" )
  $(selector).addClass( prop )

#focus on name Field
$("#clientName").focus()

$(".subscriber_stream_content").mouseenter ->
  $(this).find('.flagUser').show()
$(".subscriber_stream_content").mouseleave ->
  $(this).find('.flagUser').hide()

# Update server Client data
updateClientData = ->
  $.ajax {
    type: "PUT",
    url: "/clients/#{window.myClient.id}.json",
    data: JSON.stringify(window.myClient),
    contentType: 'application/json',
    dataType: 'json',
    success: (data) ->
      console.log('Saved client data to server')
      console.log(data)
    error: (jqHXR, textStatus) ->
      console.log("failed to save client data to server: #{textStatus}")
  }

# Get client data for all the clients in the room
getClientData = (roomId) ->
  $.ajax {
    type: 'GET',
    url: '/clients.json',
    data: { "room" : roomId },
    contentType: 'application/json',
    dataType: 'json',
    success: (data) ->
      console.log('recieved client info from server')
      storeClientDataByCid(data)
    error: (jqHXR, textStatus) ->
      console.log("failed to recieve client info from server: #{textStatus}")
  }

# Transforms the array of clients recieved from the server to a hash
# with cid as the key
storeClientDataByCid = (data) ->
  for client in data
    window.clientsData[client.cid] = client


# remove for testing
#startExecution()
#$('#clientInfoContainer').fadeOut('fast')
#session = TB.initSession( sessionId )
#session.addEventListener 'streamCreated', streamCreatedHandler
#session.addEventListener 'sessionConnected', sessionConnectedHandler
#session.addEventListener 'streamDestroyed', destroyedStreams
#session.connect( api_key, token )
