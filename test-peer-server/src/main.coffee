
# SocketIO used to pass Peer Id

connectToPeer = (peerId) ->
  console.log 'connectToPeer', peerId
  
  remotePeer = new Peer({host: 'localhost', port: 9000})
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



peerId = null
createSocketConnectionOld = ->
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


createRoom = (e) ->
  console.log 'createRoom'
  socket = e.data.socket
  
  # Prompt for room name
  promptEl.addClass('active')
  
  promptSubmitEl.on('click', (e) ->
    name = promptInputEl.val()
    return if name is ''
    
    promptInputEl.val('')
    promptEl.removeClass('active')
    
    # Message server to create room
    socket.emit('create-room', name)
  )
  


# This function is only called when the connection to server is successful.
setSocketCallbacks = (socket) ->
  
  socket.on('set-room-count', (e) ->
    
    template = ""
    for room, count of e.roomCounts
      name = if room is '' then 'Default' else room
      template += """
        <div class='row'>
          <span class='key'>#{name}</span>
          <span class='value'>#{count}</span>
        </div>
        """
    roomTableEl.html(template)
  )
  
  # Connect UI elements
  createRoomEl.on('click', {socket: socket}, createRoom)
  
  # socket.on('requestPeerId', (sessionId) ->
  #   console.log 'requestPeerId'
  #   unless socket.socket.sessionid is sessionId
  #     socket.emit('sendPeerId', socket.socket.sessionid, peer.id)
  # )
  # 
  # socket.on('sendPeerId', (data) ->
  #   unless socket.socket.sessionid is data.sessionId
  #     unless peerId?
  #       peerId = data.peerId
  #       connectToPeer(peerId)
  # )
  

createSocketConnection = ->
  socket = io.connect('http://localhost')
  
  # Listen for status update from server
  socket.on('status', (e) ->
    if e.status is true
      setSocketCallbacks(socket)
      
      # Update status
      statusEl.text("Socket Connected")
      
      # Update app state
      stateElems.removeClass('active')
      stateCreateView.addClass('active')
  )

# Set context variables
createRoomEl = null
statusEl = null

stateElems = null
stateInitialEl = null
stateCreateView = null
roomTableEl = null
promptEl = null
promptInputEl = null
promptSubmitEl = null


DOMReady = ->
  
  # Get DOM elements
  stateElems = $("article")
  stateInitialEl = $("article[data-state='initial']")
  stateCreateView = $("article[data-state='create-view']")
  
  createRoomEl = $("button[name='create-room']")
  statusEl = $("p.status")
  roomTableEl = stateCreateView.find("div.table")
  
  promptEl = $("div.prompt")
  promptInputEl = $("input[name='create-room']")
  promptSubmitEl = $("input[name='create-room-submit']")
  
  # First create a connection with the socket server.
  # This will permit users to see who else is participating.
  createSocketConnection()


window.addEventListener('DOMContentLoaded', DOMReady, false)