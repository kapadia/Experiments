{PeerServer} = require('peer')
express = require('express')
http = require('http')
socketio = require('socket.io')

PORT = 8000
PEERPORT = 9000

# Create an express app
app = express()
server = http.createServer(app)
io = socketio.listen(server, {log: false})
server.listen(PORT)

# Create a Peer Server for WebRTC handshakes
peerServer = new PeerServer({port: PEERPORT})

console.log "Express server listening on port #{PORT}"
console.log "Peer server listening on port #{PEERPORT}"

# Serve static content
app.use( express.static("#{__dirname}/../") )

getRoomCounts = (io, socket) ->
  counts = {}
  
  # Must use setImmediate to give time for pruning of clients
  setImmediate ( ->
    
    # Get list of rooms for client socket
    rooms = io.sockets.manager.roomClients[socket.id]
    
    for k, v of io.sockets.manager.rooms
      counts[k] = v.length
    io.sockets.emit 'set-room-count',
      roomCounts: counts
      rooms: rooms
  )

io.sockets.on('connection', (socket) ->
  
  # Socket disconnect event
  socket.on('disconnect', ->
    # Broadcast updated room counts
    getRoomCounts(io, socket)
  )
  
  # Emit status on successful connection for client
  socket.emit "status",
    status: true
  getRoomCounts(io, socket)
  
  # Listen for messages from client
  socket.on('create-room', (name) ->
    
    # Check if room name exists
    socket.join(name)
    getRoomCounts(io, socket)
  )
)