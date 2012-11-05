source = $("#room-template").html()
roomTemplate = Handlebars.compile(source)

pusher = new Pusher('9b96f0dc2bd6198af8ed')
channel = pusher.subscribe('newroom')
console.log $('#room-template').html()

channel.bind 'new', (data) ->
  $('table').append( roomTemplate(data) )

$('.room_view').click ->
  roomId=$(this).attr('room')
  $('#client_room_id').val( roomId )

# OpenTok Code:
apiKey = "21393201"
publisher = TB.initPublisher apiKey, 'myPublisher', {width:400, height:300}

$('#testButton').click ->
  console.log publisher.getImgData()


$("#new_client").submit ->
  imgData = publisher.getImgData()
  if imgData?
    $("#client_imgdata").val( imgData )
    $("#new_client")[0].submit()
  else
    alert "Please allow chrome to access your camera"
  return false
