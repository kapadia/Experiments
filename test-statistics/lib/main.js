// Generated by CoffeeScript 1.6.0
(function() {
  var domReady, getData, getExtent, getExtentAsync, getHistogram;

  getExtentAsync = function(arr, nWorkers) {
    var array, arrays, fn, i, index, maxs, mins, onMessageBlob, onMessageUrl, onmessage, startIndex, startTime, subArrayLength, worker, workers, _results;
    if (nWorkers == null) {
      nWorkers = 1;
    }
    startTime = new Date();
    arrays = [];
    subArrayLength = ~~(arr.length / nWorkers);
    i = nWorkers;
    while (i--) {
      startIndex = i * subArrayLength;
      arrays.push(arr.subarray(startIndex, startIndex + subArrayLength));
    }
    onmessage = function(e) {
      var max, min, value;
      arr = new Float32Array(e.data.arr);
      i = arr.length - 1;
      min = max = arr[i];
      while (i--) {
        value = arr[i];
        if (value < min) {
          min = value;
        }
        if (value > max) {
          max = value;
        }
      }
      return postMessage({
        min: min,
        max: max
      });
    };
    fn = onmessage.toString().replace('return postMessage', 'self.postMessage');
    fn = "onmessage = " + fn;
    onMessageBlob = new Blob([fn], {
      type: "application/javascript"
    });
    onMessageUrl = URL.createObjectURL(onMessageBlob);
    mins = [];
    maxs = [];
    workers = {};
    while (nWorkers--) {
      worker = new Worker(onMessageUrl);
      worker.index = nWorkers;
      worker.onmessage = function(e) {
        var data, endTime, max, min, nRemainingWorkers;
        data = e.data;
        mins.push(data.min);
        maxs.push(data.max);
        delete workers[this.index];
        nRemainingWorkers = Object.keys(workers).length;
        if (nRemainingWorkers === 0) {
          min = Math.min.apply(Math, mins);
          max = Math.min.apply(Math, maxs);
          endTime = new Date();
          return console.log('workers', endTime - startTime);
        }
      };
      workers[nWorkers] = worker;
    }
    _results = [];
    for (index in workers) {
      worker = workers[index];
      array = arrays.shift();
      _results.push(worker.postMessage({
        arr: array.buffer
      }, [array.buffer]));
    }
    return _results;
  };

  getExtent = function(arr) {
    var i, max, min, value;
    i = arr.length - 1;
    min = max = arr[i];
    while (i--) {
      value = arr[i];
      if (value < min) {
        min = value;
      }
      if (value > max) {
        max = value;
      }
    }
    return [min, max];
  };

  getHistogram = function(arr, min, max, nBins) {
    var dx, h, i, index, range, value, _i, _len;
    range = max - min;
    dx = range / nBins;
    h = new Uint16Array(nBins);
    for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
      value = arr[i];
      index = ~~(((value - min) / range) * nBins);
      if (index === nBins) {
        console.log('index', index, i);
      }
      h[index] += 1;
    }
    h.dx = dx;
    return h;
  };

  getData = function() {
    var arr, index, size, value, _i, _len;
    size = 5000 * 5000;
    arr = new Float32Array(size);
    for (index = _i = 0, _len = arr.length; _i < _len; index = ++_i) {
      value = arr[index];
      arr[index] = Math.random();
    }
    return arr;
  };

  domReady = function() {
    var arr, bar, formatCount, height, histogram, margin, max, min, svg, width, x, xAxis, y, _ref;
    arr = getData();
    _ref = getExtent(arr), min = _ref[0], max = _ref[1];
    histogram = getHistogram(arr, min, max, 50);
    formatCount = d3.format(",.0f");
    margin = {
      top: 10,
      right: 30,
      bottom: 30,
      left: 30
    };
    width = 960 - margin.left - margin.right;
    height = 500 - margin.top - margin.bottom;
    x = d3.scale.linear().domain([0, 1]).range([0, width]);
    y = d3.scale.linear().domain([0, d3.max(histogram)]).range([height, 0]);
    xAxis = d3.svg.axis().scale(x).orient("bottom");
    svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    bar = svg.selectAll(".bar").data(histogram).enter().append("g").attr("class", "bar").attr("transform", function(d, i) {
      return "translate(" + (x(i * histogram.dx)) + ", " + (y(d)) + ")";
    });
    bar.append("rect").attr("x", 1).attr("width", x(histogram.dx) - 1).attr("height", function(d) {
      return height - y(d);
    });
    return svg.append("g").attr("class", "x axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
  };

  window.addEventListener('DOMContentLoaded', domReady, false);

}).call(this);
