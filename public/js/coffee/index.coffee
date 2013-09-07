$("#roomName").focus()

goToRoom = ->
  roomName = $("#roomName").val().trim()
  if roomName.length <= 0
    alert "Room Name is Invalid"
    return
  $("#roomContainer").fadeOut('slow')
  window.location = "/#{roomName}"

$('#submitButton').click ->
  goToRoom()

$('#roomName').keypress (e) ->
  if (e.keyCode == 13)
    goToRoom()

verticalCenter = ->
  mtop = (window.innerHeight - $(".container").outerHeight())/2
  $(".container").css({"margin-top": "#{mtop+0.2*mtop}px"})

window.onresize = verticalCenter

verticalCenter()
