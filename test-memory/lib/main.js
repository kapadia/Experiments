// Generated by CoffeeScript 1.6.3
(function() {
  var AllocateArray, AllocateBuffer, init;

  AllocateArray = (function() {
    function AllocateArray() {
      var i, _i;
      this.chunks = [];
      for (i = _i = 0; _i <= 19; i = ++_i) {
        this.chunks.push(new Float32Array(13107200));
      }
      console.log(this.chunks);
    }

    return AllocateArray;

  })();

  AllocateBuffer = (function() {
    AllocateBuffer.prototype.bytes = 536870912;

    function AllocateBuffer() {
      this.buffer = new ArrayBuffer(this.bytes);
    }

    return AllocateBuffer;

  })();

  init = function() {
    var a2;
    console.log('init');
    return a2 = new AllocateBuffer();
  };

  init();

}).call(this);
