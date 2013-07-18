{PeerServer} = require('peer')
express = require('express')
http = require('http')
socketio = require('socket.io')

PORT = 8000
PEERPORT = 9000

# Create an express app
app = express()
server = http.createServer(app)
io = socketio.listen(server)
server.listen(PORT)

# Create a Peer Server for WebRTC handshakes
peerServer = new PeerServer({port: PEERPORT})


console.log "Express server listening on port #{PORT}"
console.log "Peer server listening on port #{PEERPORT}"

# Serve static content
app.use( express.static("#{__dirname}/../../") )

io.sockets.on('connection', (socket) ->
  console.log 'CONNECTION', socket
)