// Generated by CoffeeScript 1.6.0
(function() {
  var go, multiplyBy2;

  multiplyBy2 = function(arr) {
    var index, value, _i, _len;
    for (index = _i = 0, _len = arr.length; _i < _len; index = ++_i) {
      value = arr[index];
      arr[index] = 2 * value;
    }
    return arr;
  };

  go = function(e) {
    var arr, blob1, blob2, fn1, fn2, index, mime, onmessage, url1, url2, value, worker, _i, _len;
    arr = new Float32Array(10000000);
    for (index = _i = 0, _len = arr.length; _i < _len; index = ++_i) {
      value = arr[index];
      arr[index] = Math.random();
    }
    onmessage = function(e) {
      var data, fnUrl, i, _j;
      fnUrl = e.data.fnUrl;
      arr = e.data.arr;
      importScripts(fnUrl);
      for (i = _j = 1; _j <= 10000; i = ++_j) {
        multiplyBy2(arr);
      }
      data = multiplyBy2(arr);
      return postMessage(data);
    };
    fn1 = onmessage.toString().replace('return postMessage(data);', 'postMessage(data);');
    fn1 = "onmessage = " + fn1;
    fn2 = multiplyBy2.toString();
    fn2 = "multiplyBy2 = " + fn2;
    mime = "application/javascript";
    blob1 = new Blob([fn1], {
      type: mime
    });
    blob2 = new Blob([fn2], {
      type: mime
    });
    url1 = URL.createObjectURL(blob1);
    url2 = URL.createObjectURL(blob2);
    worker = new Worker(url1);
    worker.onmessage = function(e) {
      var data;
      data = e.data;
      console.log('done');
      URL.revokeObjectURL(url1);
      URL.revokeObjectURL(url2);
      return worker.terminate();
    };
    return worker.postMessage({
      fnUrl: url2,
      arr: arr
    });
  };

  document.addEventListener('DOMContentLoaded', function() {
    var i, _i, _results;
    _results = [];
    for (i = _i = 1; _i < 8; i = ++_i) {
      _results.push(go());
    }
    return _results;
  }, false);

}).call(this);
