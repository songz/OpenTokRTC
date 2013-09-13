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
  mtop = (window.innerHeight - $("#insideContainer").outerHeight())/2
  $("#insideContainer").css({"margin-top": "#{mtop}px"})

window.onresize = verticalCenter

verticalCenter()
