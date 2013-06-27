// Generated by CoffeeScript 1.6.0
(function() {
  var Allocate, GPUHack, gpuHack;

  Allocate = (function() {

    function Allocate() {
      var i, _i;
      this.chunks = [];
      for (i = _i = 0; _i <= 19; i = ++_i) {
        this.chunks.push(new Float32Array(13107200));
      }
      console.log(this.chunks);
    }

    return Allocate;

  })();

  GPUHack = (function() {

    GPUHack.prototype.dimension = 4096;

    function GPUHack() {
      var el;
      console.log('GPUHack');
      el = document.querySelector('#container');
      this.webfits = new astro.WebFITS(el, this.dimension);
    }

    GPUHack.prototype.overloadTexture = function() {
      var arr, i, _i, _results;
      _results = [];
      for (i = _i = 0; _i <= 15; i = ++_i) {
        arr = new Float32Array(this.dimension * this.dimension);
        _results.push(this.webfits.loadImage("fake-data-" + i, arr, this.dimension, 1));
      }
      return _results;
    };

    return GPUHack;

  })();

  gpuHack = new GPUHack();

  setTimeout((function() {
    return gpuHack.overloadTexture();
  }), 500);

}).call(this);
