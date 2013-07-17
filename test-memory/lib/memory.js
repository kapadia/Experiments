// Generated by CoffeeScript 1.6.3
(function() {
  var AMOUNT, DOMReady, HALFGIG, ONEGIG, TWOGIGS, allocateOnce;

  TWOGIGS = 2147483648;

  ONEGIG = 1073741824;

  HALFGIG = 536870912;

  AMOUNT = ONEGIG;

  allocateOnce = function() {
    var arr, nElements, _results;
    console.log('allocateOnce');
    nElements = AMOUNT / 4;
    arr = new Float32Array(nElements);
    _results = [];
    while (nElements--) {
      _results.push(arr[nElements] = Math.random());
    }
    return _results;
  };

  DOMReady = function() {
    var arr, fT, sT;
    sT = new Date();
    arr = allocateOnce();
    fT = new Date();
    return console.log(fT - sT);
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);