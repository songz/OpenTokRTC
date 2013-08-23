// ***
// *** Required modules
// ***
var express = require('express');
var Firebase = require('firebase');
var OpenTokLibrary = require('opentok');

// ***
// *** OpenTok Constants for creating Session and Token values
// ***
var OTKEY = process.env.TB_KEY;
var OTSECRET = process.env.TB_SECRET;
var OpenTokObject = new OpenTokLibrary.OpenTokSDK(OTKEY, OTSECRET);

// ***
// *** Setup Express to handle static files in public folder
// *** Express is also great for handling url routing
// ***
var app = express();
app.use(express.static(__dirname + '/public'));
app.set( 'views', __dirname + "/views");
app.set( 'view engine', 'ejs' );

// ***
// *** When user goes to root directory, render index page
// ***
app.get("/", function( req, res ){
  if(req.header('x-forwarded-proto')!="https"){
    res.redirect( 'https://opentokrtc.com' );
  }else{
    res.render( 'index' );
  }
});

var presenceListener = {};
app.get("/:rid", function( req, res ){
  if(req.header('x-forwarded-proto')!="https"){
    res.redirect( 'https://opentokrtc.com'+req.url );
    return;
  }

  // find request format, json or html?
  var path = req.params.rid.split(".json");
  var rid = path[0];
  var roomRef = new Firebase("https://rtcdemo.firebaseIO.com/room/" + rid);

  // on incoming request, make sure we have presenceListener to remove the room if it is empty
  if( !presenceListener[rid] ){
    presenceListener[rid] = true
    var presenceRef = new Firebase("https://rtcdemo.firebaseIO.com/room/" + rid + "/users");
    presenceRef.on('value', function(dataSnapshot){
      if(dataSnapshot.numChildren() == 0){
        // remove room if there is no one in the room
        roomRef.remove();
      }
    });
  }

  // Generate sessionId if there are no existing session Id's
  roomRef.once('value', function(dataSnapshot){
    var sidSnapshot = dataSnapshot.child('sid');
    var sid = sidSnapshot.val();
    if(!sid){
      OpenTokObject.createSession(function(sessionId){
        sidSnapshot.ref().set( sessionId );
        returnRoomResponse( res, { rid: rid, sid: sessionId }, path[1]);
      });
    }else{
      returnRoomResponse( res, { rid: rid, sid: sid }, path[1]);
    }
  });
});

function returnRoomResponse( res, data, json ){
  data.apiKey = OTKEY;
  data.token = OpenTokObject.generateToken( {session_id: data.sid, role:OpenTokLibrary.RoleConstants.MODERATOR} );
  if( json == "" ){
    res.json( data );
  }else{
    res.render( 'room', data );
  }
}

// ***
// *** start server, listen to port (predefined or 9393)
// ***
var port = process.env.PORT || 5000;
app.listen(port);
