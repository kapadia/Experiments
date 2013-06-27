
connections = {}

connect = ->
  
  # Create a new peer
  peer = new Peer("http://webrtcb.jit.su:80", {
    binaryType: 'arraybuffer',
    video: false,
    audio: false
  })
  
  peer.listen()
  
  peer.onconnection = (connection) ->
    connections[connection.id] = connection
    console.log connections


DOMReady = ->
  console.log 'DOMContentLoaded'
  
  button = document.querySelector("button[name='connect-to-peer']")
  button.onclick = connect

window.addEventListener('DOMContentLoaded', DOMReady, false)