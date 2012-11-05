myId = ""
api_key = '21393201'
publisher = TB.initPublisher( api_key, "myPublisher" )
sessionId = $('#info').attr('tbSession')
token = $("#info").attr('tbToken')

position = ""

$('#retake').click ->
  console.log( publisher )
  img = publisher.getImgData()
  $('#preview_img').attr('src', "data:image/png;base64,#{img}")

$("#confirmButton").click ->
  img = $('#myPicture').attr('src')
  $.post("/users/#{myId}", {user: {imgdata:img, room_id:$("#info").attr('room_id')}} )
  $("#publisher").remove()

Pusher.channel_auth_transport = 'jsonp'
Pusher.channel_auth_endpoint = '/pusher/auth'
pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe("presence-#{sessionId}")

channel.bind 'pusher:subscription_succeeded', ->
  myId = channel.members.me.id
  count = channel.members.count
  console.log("you are user number: "+count)
  console.log("Your user ID is: "+myId)




RECORD = "Record Videos"
RSTOP = "Stop Recording"
DOWNLOAD = "Process Video"
PROCESS = "Video Processing..."
READY = "Download"

interval = ""
key = api_key
sessionId = $('#info').attr('tbSession')
token = $('#info').attr('tbToken')
downloadURL=""
users = 0

TB.setLogLevel(TB.DEBUG)

parseArchiveResponse = (response) ->
  console.log response
  if response.status != "fail"
    window.clearInterval(interval)
    $('#startRecording').text(READY)
    downloadURL = 'http://'+response.url.split('https://')[1]

getDownloadUrl = ->
  $.post "/archive/#{window.archive.archiveId}", {token:$('#info').attr('tbToken')}, parseArchiveResponse

setRecordingCapability = ->
    $('#startRecording').show()
    $('#startRecording').text(RECORD)
    $('#startRecording').click ->
      console.log "button click"
      console.log window.archive
      switch $(@).text()
        when RECORD
          if window.archive==""
            session.createArchive( key, 'perSession', "#{Date.now()}")
          else
            session.startRecording(window.archive)
          $(@).text(RSTOP)
        when RSTOP
          session.stopRecording( window.archive )
          session.closeArchive( window.archive )
          $(@).text(PROCESS)
        when READY
          window.open( downloadURL )

archiveClosedHandler = (event) ->
  console.log window.archive
  interval = window.setInterval(getDownloadUrl, 5000)

archiveCreatedHandler = (event) ->
  window.archive = event.archives[0]
  session.startRecording(window.archive)
  console.log window.archive

archiveLoadedHandler = (event) ->
  window.archive = event.archives[0]
  window.archive.startPlayback()

window.archive = ""
window.users = 0

subscribeStreams = (streams) ->
  for stream in streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    console.log stream.name
    newDiv = $("<div />", {id:"div#{stream.name}"})
    $("##{stream.name}").append newDiv
    session.subscribe( stream, "div#{stream.name}", {width:259, height: 189} )
    users += 1

sessionConnectedHandler = (event) ->
  console.log event.archives
  if event.archives[0]
    window.archive=event.archives[0]
  users = event.streams.length
  if users==0
    setRecordingCapability()
  subscribeStreams(event.streams)

streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)

destroyedStreams = (e) ->
  users -= 1
  if users==0 # including myself
    setRecordingCapability()
  for stream in e.streams
    if session.connection.connectionId == stream.connection.connectionId
      return
    name = stream.name
    console.log name

TB.setLogLevel( TB.DEBUG )
session = TB.initSession( sessionId )

session.addEventListener 'streamCreated', streamCreatedHandler
session.addEventListener 'sessionConnected', sessionConnectedHandler
session.addEventListener 'streamDestroyed', destroyedStreams
session.addEventListener 'archiveCreated', archiveCreatedHandler
session.addEventListener 'archiveClosed', archiveClosedHandler
session.addEventListener 'archiveLoaded', archiveLoadedHandler

session.connect( api_key, token )












dataRef = new Firebase("https://gamma.firebase.com/song/actroulette/#{sessionId}")
console.log $('#messageInput')
$('#messageInput').keydown (e) ->
  console.log e.keyCode
  if (e.keyCode == 13)
    text = $('#messageInput').val()
    dataRef.push({name: userName, text: text})
    $('#messageInput').val('')

dataRef.on 'child_added', (snapshot) ->
  message = snapshot.val()
  text = message.text
  name = message.name
  $('<div/>').text(text).prepend($('<em/>').text(name+': ')).appendTo($('#displayChat'))
  $('#displayChat')[0].scrollTop = $('#displayChat')[0].scrollHeight

$(".joinButton").click ->
  position = $(@).attr('stream')

$('#finishPictureButton').click ->
  publisher = TB.initPublisher( api_key, position, {width:259, height: 189, name:position} )
  session.publish( publisher )
  $(".joinButton").remove()

