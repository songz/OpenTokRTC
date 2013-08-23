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

mtop = (window.innerHeight - $(".container").height())/3
$(".container").css({"margin-top": "#{mtop}px"})
window.onresize = ->
  mtop = (window.innerHeight - $(".container").height())/3
  $(".container").css({"margin-top": "#{mtop}px"})
