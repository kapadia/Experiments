
# SocketIO used to pass Peer Id

connectToPeer = (peerId) ->
  console.log 'connectToPeer', peerId
  
  remotePeer = new Peer({host: 'localhost', port: 9000})
  # remotePeer = new Peer({key: 'wfueqmp6rb18xgvi'})
  c = remotePeer.connect(peerId, {reliable: true})
  
  # Initialize a FITS file
  new astro.FITS('lib/m101.fits', (fits) ->
    dataunit = fits.getDataUnit()
    dataunit.getFrame(0, (arr) ->
      
      # Create a Uint8 representation
      uint8 = new Uint8Array(arr.buffer)
      
      # GZip before sending
      gzip = new Zlib.Gzip(uint8)
      compressed = gzip.compress()
      
      # Send compressed array
      c.send(compressed)
    )
  )


socket = null
peerId = null
createSocketConnection = ->
  socket = io.connect()
  
  socket.on('status', (e) ->
    if e.status is true
      alert 'hey hey hey'
      # Define callback for peer id event
      socket.on('requestPeerId', (sessionId) ->
        console.log 'requestPeerId'
        unless socket.socket.sessionid is sessionId
          socket.emit('sendPeerId', socket.socket.sessionid, peer.id)
      )
      
      socket.on('sendPeerId', (data) ->
        unless socket.socket.sessionid is data.sessionId
          unless peerId?
            peerId = data.peerId
            connectToPeer(peerId)
      )
      
    else
      alert 'Socket connection fails.'
  )

peer = null
createPeerConnection = ->
  
  # Create Peer object
  peer = new Peer({host: 'localhost', port: 9000, debug: false})
  # peer = new Peer({key: 'wfueqmp6rb18xgvi'})
  
  peer.on('open', (id) ->
    console.log 'peer open', id
  )
  
  # Await connection from others
  peer.on('connection', (c) ->
    console.log 'connection'
    
    c.on('data', (buffer) ->
      
      # Initialize a Uint8Array from buffer
      compressed = new Uint8Array(buffer)
      
      # Gunzip array
      gunzip = new Zlib.Gunzip(compressed)
      uint8 = gunzip.decompress()
      
      # Cast back to correct data type
      arr = new Uint16Array(uint8.buffer)
      console.log arr
    )
  )

requestPeerId = (e) ->
  
  # Disable button to prevent unnecessary connections
  button = $(e.target)
  button.attr('disabled', 'disabled')
  
  socket.emit('requestPeerId', socket.socket.sessionid)


DOMReady = ->
  createSocketConnection()
  createPeerConnection()
  
  button = document.querySelector("button[name='connect-to-peer']")
  button.onclick = requestPeerId

window.addEventListener('DOMContentLoaded', DOMReady, false)