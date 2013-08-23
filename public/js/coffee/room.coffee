window.onresize = ->
  ResizeLayoutContainer()

class User
  constructor: (@rid, @apiKey, @sid, @token) ->
    # templates
    @messageTemplate = Handlebars.compile( $("#messageTemplate").html() )
    @userStreamTemplate = Handlebars.compile( $("#userStreamTemplate").html() )
    @notifyTemplate = Handlebars.compile( $("#notifyTemplate").html() )

    # variables
    @takenNames = {}

    # Creating data references
    @roomRef = new Firebase("https://rtcdemo.firebaseIO.com/room/#{@rid}")
    @chatRef = new Firebase("https://rtcdemo.firebaseIO.com/room/#{@rid}/chat/")
    @usersRef = new Firebase("https://rtcdemo.firebaseIO.com/room/#{@rid}/users/")

    @usersRef.on "child_added", (childSnapshot, prevChildName) =>
      @takenNames[childSnapshot.val().name] = true
      @displayChatMessage( @notifyTemplate( {message: "#{childSnapshot.val().name} has joined the room" } ) )
    @usersRef.on "child_removed", (childSnapshot) =>
      @takenNames[childSnapshot.val().name] = false
      @displayChatMessage( @notifyTemplate( {message: "#{childSnapshot.val().name} has left the room" } ) )

    @usersRef.on "child_changed", (childSnapshot, prevChildName) =>
      console.log childSnapshot.name()
      val = childSnapshot.val()
      if val.filter
        self.applyClassFilter( val.filter, ".stream#{childSnapshot.name()}" )
      @takenNames[childSnapshot.val().name] = true

    # set up session id for the room
    @roomRef.once 'value', (snapshot) =>
      if !snapshot.child("sid").val()
        snapshot.child("sid").ref().set( @sid )

    # set up message input
    @chatRef.on 'child_added', (snapshot) =>
      val = snapshot.val()
      text = val.text.split(' ')
      if text[0] == "/serv"
        @displayChatMessage( @notifyTemplate( {message: val.text.split("/serv")[1] } ) )
        return
      message = ""
      urlRegex = /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/g
      for e in text
        if e.match( urlRegex ) and e.split("..").length < 2 and e[e.length-1] != "."
          message += e.replace( urlRegex,"<a href='http://$2.$3$4' target='_blank'>$1$2.$3$4<a>" )+" "
        else
          message += Handlebars.Utils.escapeExpression(e) + " "
      val.text = message
      @displayChatMessage( @messageTemplate( val ) )
    $('#messageInput').keypress @inputKeypress

    # set up OpenTok
    @publisher = TB.initPublisher( @apiKey, "myPublisher", {width:240, height:190} )
    @session = TB.initSession( @sid )
    @session.on( "sessionConnected", @sessionConnectedHandler )
    @session.on( "streamCreated", @streamCreatedHandler )
    @session.on( "streamDestroyed", @streamDestroyedHandler )
    @session.on( "sessionDisconnected", @sessionDisconnectedHandler )
    @session.connect( @apiKey, @token )

    # add event listeners
    self = @
    $(".filterOption").click ->
      $(".filterOption").removeClass("optionSelected")
      prop = $(@).data('value')
      self.applyClassFilter( prop, "#myPublisher" )
      $(@).addClass("optionSelected")
      self.presenceRef.child("filter").set prop

  applyClassFilter: (prop, selector) ->
    $(selector).removeClass( "Blur Sepia Grayscale Invert" )
    $(selector).addClass( prop )
    console.log "applyclassfilter..."+prop

  removeStream: (cid) =>
    element$ = $(".stream#{cid}")
    element$.remove()
  subscribeStreams: (streams) =>
    for stream in streams
      streamConnectionId = stream.connection.connectionId
      if @session.connection.connectionId == streamConnectionId
        return
      # create new div container for stream
      divId = "stream#{streamConnectionId}"
      $("#streams_container").append( @userStreamTemplate({ id: divId }) )
      @session.subscribe( stream, divId , {width:240, height:190} )

      divId$ = $(".#{divId}")
      divId$.mouseenter ->
        $(@).find('.flagUser').show()
      divId$.mouseleave ->
        $(@).find('.flagUser').hide()

      self = @
      divId$.find('.flagUser').click ->
        streamConnection = $(@).data('streamconnection')
        if confirm("Is this user being inappropriate? If so, we are sorry that you had to go through that. Click confirm to remove user")
          self.applyClassFilter("Blur", ".#{streamConnection}")
          self.session.forceDisconnect( streamConnection.split("stream")[1] )

      # Apply any existing filters to the video element
      streamRef = new Firebase("https://rtcdemo.firebaseIO.com/room/#{@rid}/users/#{streamConnectionId}/filter")
      streamRef.once 'value', (dataSnapshot) =>
        val = dataSnapshot.val()
        @applyClassFilter( val, ".stream#{streamConnectionId}" )
  sessionConnectedHandler: (event) =>
    console.log "session connected"
    @subscribeStreams(event.streams)
    @session.publish( @publisher )
    ResizeLayoutContainer()

    date = "#{Date.now()}"
    @name = "Guest#{date.substring( date.length - 8, date.length )}"
    @myConnectionId = @session.connection.connectionId
    @presenceRef = new Firebase("https://rtcdemo.firebaseIO.com/room/#{@rid}/users/#{@myConnectionId}")
    @presenceRef.child("name").set @name
    @presenceRef.onDisconnect().remove()
    $("#messageInput").removeAttr( "disabled" )
    $('#messageInput').focus()
    setTimeout =>
      @displayChatMessage( @notifyTemplate( {message: "-----------"} ) )
      @displayChatMessage( @notifyTemplate( {message: "Welcome to OpenTokRTC."} ) )
      @displayChatMessage( @notifyTemplate( {message: "Type /name <value> to change your name"} ) )
      @displayChatMessage( @notifyTemplate( {message: "-----------"} ) )
    , 2000
  sessionDisconnectedHandler: (event) =>
    console.log event.reason
    if( event.reason == "forceDisconnected" )
      alert "Someone in the room found you offensive and removed you. Please evaluate your behavior"
    else
      alert "You have been disconnected! Please try again"
    window.location = "/"
  streamDestroyedHandler: (event) =>
    for stream in event.streams
      if @session.connection.connectionId == stream.connection.connectionId
        return
      @removeStream( stream.connection.connectionId )
    ResizeLayoutContainer()
  streamCreatedHandler: (event) =>
    console.log "streamCreated"
    @subscribeStreams(event.streams)
    ResizeLayoutContainer()
  inputKeypress: (e) =>
    if (e.keyCode == 13)
      text = $('#messageInput').val().trim()
      if text.length < 1
        return
      parts = text.split(' ')
      if parts[0] == "/name"
        if @takenNames[parts[1]]
          alert("Sorry, but that name has already been taken.")
          return
        @chatRef.push({name: @name, text: "/serv #{@name} is now known as #{parts[1]}"})
        @name = parts[1]
        @presenceRef.child("name").set @name
      else
        @chatRef.push({name: @name, text: text})
      $('#messageInput').val('')
  displayChatMessage: (message)->
    $("#displayChat").append message
    $('#displayChat')[0].scrollTop = $('#displayChat')[0].scrollHeight
window.User = User
