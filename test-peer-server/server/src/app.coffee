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
  )

getRoomCount = (io, socket, room) ->
  setImmediate ( ->
    attendees = io.sockets.clients(room)
    attendees = attendees.map( (attendee) -> return attendee.id )
    io.sockets.emit "set-room-attendence", attendees
  )

io.sockets.on('connection', (socket) ->
  
  socket.on('disconnect', ->
    getRoomCounts(io, socket)
    
    rooms = io.sockets.manager.roomClients[socket.id]
    for room, state of rooms
      room = room.slice(1)
      getRoomCount(io, socket, room)
  )
  
  socket.on('create-room', (name) ->
    socket.join(name)
    getRoomCounts(io, socket)
  )
  
  socket.on('get-room-attendence', (room) ->
    setImmediate ( ->
      attendees = io.sockets.clients(room)
      attendees = attendees.map( (attendee) -> return attendee.id )
      io.sockets.emit "set-room-attendence", attendees
    )
  )
  
  socket.on('join-room', (room) ->
    socket.join(room)
    getRoomCounts(io, socket)
    
    socket.emit 'joined-room', room
  )
  
  socket.emit "status", socket.id
  getRoomCounts(io, socket)
)