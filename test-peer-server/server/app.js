// Generated by CoffeeScript 1.6.3
(function() {
  var PEERPORT, PORT, PeerServer, app, express, http, io, peerServer, server, socketio;

  PeerServer = require('peer').PeerServer;

  express = require('express');

  http = require('http');

  socketio = require('socket.io');

  PORT = 8000;

  PEERPORT = 9000;

  app = express();

  server = http.createServer(app);

  io = socketio.listen(server);

  server.listen(PORT);

  peerServer = new PeerServer({
    port: PEERPORT
  });

  console.log("Express server listening on port " + PORT);

  console.log("Peer server listening on port " + PEERPORT);

  app.use(express["static"]("" + __dirname + "/../"));

  io.sockets.on('connection', function(socket) {
    return console.log('CONNECTION', socket);
  });

}).call(this);
