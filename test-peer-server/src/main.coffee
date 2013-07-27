
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


joinedRoom = (name, socket) ->
  socket.emit('get-room-attendence', name)
  

createRoom = (e) ->
  socket = e.data.socket
  el = stateElems['create-room']
  
  submit = el.find('input[type="submit"]')
  submit.one('click', (e) ->
    nameEl = el.find('input[name="create-room"]')
    name = nameEl.val()
    return if name is ''
    
    nameEl.val('')
    changeState('in-room', "Joined Room #{name}", true, joinedRoom, [name, socket])
    socket.emit('create-room', name)
  )
  changeState('create-room', null, false)


# This function is only called when the connection to server is successful.
setSocketCallbacks = (socket) ->
  
  socket.on('set-room-count', (e) ->
    
    template = ""
    for room, count of e.roomCounts
      continue if room is ''
      
      name = room.slice(1)
      template += """
        <div class='row'>
          <span class='key'>#{name}</span>
          <span class='value'>#{count}</span>
          <span class='join' data-room="#{name}">join</span>
        </div>
        """
    roomTableEl.html(template)
  )
  
  # Connect UI elements
  createRoomBtn.on('click', {socket: socket}, createRoom)
  
  $(document).on('click', "span.join", (e) ->
    room = e.target.dataset.room
    socket.emit 'join-room', room
  )
  
  socket.on('set-room-attendence', (attendees) ->
    el = stateElems['in-room'].find('.attendees')
    template = ""
    for attendee in attendees
      template += "<li class='attendee'>#{attendee}</li>"
    el.html(template)
  )
  
  socket.on('joined-room', (room) ->
    changeState('in-room', "Joined Room #{room}", true, joinedRoom, [room, socket])
  )
  
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
  socket = io.connect()
  
  # Listen for status update from server
  socket.on('status', (id) ->
    setSocketCallbacks(socket)
    changeState('create-join', "Socket Connected")
    $("p.socket-id").text(id)
  )

# Set context variables
createRoomBtn = null
roomTableEl = null

stateElems = {}
statusEl = null


DOMReady = ->
  window.removeEventListener('DOMContentLoaded', DOMReady, false)
  
  stateElems['all'] = $("article")
  states = stateElems['all'].map( (i, d) -> return d.dataset.state )
  
  for state in states
    stateElems[state] = $("article[data-state='#{state}']")
  statusEl = $("p.status")
  
  # Get UI elements
  # TODO: Stashing these like so is not scalable, find better solution.
  createRoomBtn = stateElems['create-join'].find("button[name='create-room']")
  roomTableEl = stateElems['create-join'].find('div.table')
  
  # First create a connection with the socket server.
  # This will permit users to see who else is participating.
  createSocketConnection()


# Utility functions
changeState = (state, status = null, hideOthers = true, callback, args) ->
  stateElems['all'].removeClass('active') if hideOthers
  statusEl.text(status) if status
  $("article[data-state='#{state}']").addClass('active')
  
  callback.apply(null, args) if callback?


window.addEventListener('DOMContentLoaded', DOMReady, false)