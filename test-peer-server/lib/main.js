// Generated by CoffeeScript 1.6.3
(function() {
  var DOMReady, changeState, connectToPeer, createPeerConnection, createRoom, createRoomBtn, createSocketConnection, createSocketConnectionOld, joinedRoom, peer, peerId, requestPeerId, roomTableEl, setSocketCallbacks, stateElems, statusEl;

  connectToPeer = function(peerId) {
    var c, remotePeer;
    console.log('connectToPeer', peerId);
    remotePeer = new Peer({
      host: 'localhost',
      port: 9000
    });
    c = remotePeer.connect(peerId, {
      reliable: true
    });
    return new astro.FITS('lib/m101.fits', function(fits) {
      var dataunit;
      dataunit = fits.getDataUnit();
      return dataunit.getFrame(0, function(arr) {
        var compressed, gzip, uint8;
        uint8 = new Uint8Array(arr.buffer);
        gzip = new Zlib.Gzip(uint8);
        compressed = gzip.compress();
        return c.send(compressed);
      });
    });
  };

  peerId = null;

  createSocketConnectionOld = function() {
    var socket;
    socket = io.connect();
    return socket.on('status', function(e) {
      if (e.status === true) {
        alert('hey hey hey');
        socket.on('requestPeerId', function(sessionId) {
          console.log('requestPeerId');
          if (socket.socket.sessionid !== sessionId) {
            return socket.emit('sendPeerId', socket.socket.sessionid, peer.id);
          }
        });
        return socket.on('sendPeerId', function(data) {
          if (socket.socket.sessionid !== data.sessionId) {
            if (peerId == null) {
              peerId = data.peerId;
              return connectToPeer(peerId);
            }
          }
        });
      } else {
        return alert('Socket connection fails.');
      }
    });
  };

  peer = null;

  createPeerConnection = function() {
    peer = new Peer({
      host: 'localhost',
      port: 9000,
      debug: false
    });
    peer.on('open', function(id) {
      return console.log('peer open', id);
    });
    return peer.on('connection', function(c) {
      console.log('connection');
      return c.on('data', function(buffer) {
        var arr, compressed, gunzip, uint8;
        compressed = new Uint8Array(buffer);
        gunzip = new Zlib.Gunzip(compressed);
        uint8 = gunzip.decompress();
        arr = new Uint16Array(uint8.buffer);
        return console.log(arr);
      });
    });
  };

  requestPeerId = function(e) {
    var button;
    button = $(e.target);
    button.attr('disabled', 'disabled');
    return socket.emit('requestPeerId', socket.socket.sessionid);
  };

  joinedRoom = function(name, socket) {
    return socket.emit('get-room-attendence', name);
  };

  createRoom = function(e) {
    var el, socket, submit;
    socket = e.data.socket;
    el = stateElems['create-room'];
    submit = el.find('input[type="submit"]');
    submit.one('click', function(e) {
      var name, nameEl;
      nameEl = el.find('input[name="create-room"]');
      name = nameEl.val();
      if (name === '') {
        return;
      }
      nameEl.val('');
      changeState('in-room', "Joined Room " + name, true, joinedRoom, [name, socket]);
      return socket.emit('create-room', name);
    });
    return changeState('create-room', null, false);
  };

  setSocketCallbacks = function(socket) {
    socket.on('set-room-count', function(e) {
      var count, name, room, template, _ref;
      template = "";
      _ref = e.roomCounts;
      for (room in _ref) {
        count = _ref[room];
        if (room === '') {
          continue;
        }
        name = room.slice(1);
        template += "<div class='row'>\n  <span class='key'>" + name + "</span>\n  <span class='value'>" + count + "</span>\n  <span class='join' data-room=\"" + name + "\">join</span>\n</div>";
      }
      return roomTableEl.html(template);
    });
    createRoomBtn.on('click', {
      socket: socket
    }, createRoom);
    $(document).on('click', "span.join", function(e) {
      var room;
      room = e.target.dataset.room;
      return socket.emit('join-room', room);
    });
    socket.on('set-room-attendence', function(attendees) {
      var attendee, el, template, _i, _len;
      el = stateElems['in-room'].find('.attendees');
      template = "";
      for (_i = 0, _len = attendees.length; _i < _len; _i++) {
        attendee = attendees[_i];
        template += "<li class='attendee'>" + attendee + "</li>";
      }
      return el.html(template);
    });
    return socket.on('joined-room', function(room) {
      return changeState('in-room', "Joined Room " + room, true, joinedRoom, [room, socket]);
    });
  };

  createSocketConnection = function() {
    var socket;
    socket = io.connect();
    return socket.on('status', function(id) {
      setSocketCallbacks(socket);
      changeState('create-join', "Socket Connected");
      return $("p.socket-id").text(id);
    });
  };

  createRoomBtn = null;

  roomTableEl = null;

  stateElems = {};

  statusEl = null;

  DOMReady = function() {
    var state, states, _i, _len;
    window.removeEventListener('DOMContentLoaded', DOMReady, false);
    stateElems['all'] = $("article");
    states = stateElems['all'].map(function(i, d) {
      return d.dataset.state;
    });
    for (_i = 0, _len = states.length; _i < _len; _i++) {
      state = states[_i];
      stateElems[state] = $("article[data-state='" + state + "']");
    }
    statusEl = $("p.status");
    createRoomBtn = stateElems['create-join'].find("button[name='create-room']");
    roomTableEl = stateElems['create-join'].find('div.table');
    return createSocketConnection();
  };

  changeState = function(state, status, hideOthers, callback, args) {
    if (status == null) {
      status = null;
    }
    if (hideOthers == null) {
      hideOthers = true;
    }
    if (hideOthers) {
      stateElems['all'].removeClass('active');
    }
    if (status) {
      statusEl.text(status);
    }
    $("article[data-state='" + state + "']").addClass('active');
    if (callback != null) {
      return callback.apply(null, args);
    }
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);
