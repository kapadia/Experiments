// Generated by CoffeeScript 1.6.0
(function() {
  var domReady, onDragOver, onDrop, readBinary1;

  onDragOver = function(e) {
    e.stopPropagation();
    return e.preventDefault();
  };

  onDrop = function(e) {
    var blob, end, file, nElements, start;
    e.stopPropagation();
    e.preventDefault();
    file = e.dataTransfer.files[0];
    start = 54720;
    end = start + 482344960;
    nElements = 120586240;
    blob = file.slice(start, end);
    return readBinary1(blob, 4);
  };

  readBinary1 = function(blob, nWorkers) {
    var arr, b, blobArrays, blobRemainder, blobSize, blobs, blobsPerArray, bufferArrays, chunkSize, fn, i, index, nChunks, obj, onMessageBlob, onMessageUrl, onmessage, startByte, startTime, worker, workers, _results;
    startTime = new Date();
    chunkSize = 16777216;
    blobSize = blob.size;
    nChunks = i = Math.ceil(blobSize / chunkSize);
    blobs = [];
    while (i--) {
      startByte = i * chunkSize;
      obj = {
        startByte: startByte,
        slice: blob.slice(startByte, startByte + chunkSize)
      };
      blobs.push(obj);
    }
    blobArrays = [];
    blobsPerArray = ~~(nChunks / nWorkers);
    blobRemainder = nChunks % blobsPerArray;
    while (blobs.length > blobRemainder) {
      blobArrays.push(blobs.splice(0, blobsPerArray));
    }
    i = 0;
    while (blobRemainder--) {
      blobArrays[i].push(blobs.splice(0, 1)[0]);
      i += 1;
    }
    arr = new Float32Array(blobSize / 4);
    onmessage = function(e) {
      var buffer, reader, value;
      obj = e.data;
      reader = new FileReaderSync();
      buffer = reader.readAsArrayBuffer(obj.slice);
      arr = new Uint32Array(buffer);
      i = arr.length;
      while (i--) {
        value = arr[i];
        arr[i] = ((value & 0xFF) << 24) | ((value & 0xFF00) << 8) | ((value >> 8) & 0xFF00) | ((value >> 24) & 0xFF);
      }
      buffer = arr.buffer;
      return postMessage({
        startByte: obj.startByte,
        buffer: buffer
      }, [buffer]);
    };
    fn = onmessage.toString().replace('return postMessage', 'self.postMessage');
    fn = "onmessage = " + fn;
    onMessageBlob = new Blob([fn], {
      type: "application/javascript"
    });
    onMessageUrl = URL.createObjectURL(onMessageBlob);
    bufferArrays = [];
    workers = {};
    while (nWorkers--) {
      worker = new Worker(onMessageUrl);
      worker.index = nWorkers;
      worker.onmessage = function(e) {
        var b, buffers, data, docFrag, endTime, nRemainingWorkers, p, time, _i, _j, _len, _len1;
        data = e.data;
        startByte = data.startByte;
        bufferArrays[this.index].push(data);
        blobs = blobArrays[this.index];
        b = blobs.shift();
        if (b != null) {
          return this.postMessage(b);
        } else {
          delete workers[this.index];
          nRemainingWorkers = Object.keys(workers).length;
          if (nRemainingWorkers === 0) {
            endTime = new Date();
            time = endTime - startTime;
            docFrag = document.createDocumentFragment();
            p = document.createElement('p');
            p.textContent = time;
            docFrag.appendChild(p);
            document.body.appendChild(docFrag);
            for (_i = 0, _len = bufferArrays.length; _i < _len; _i++) {
              buffers = bufferArrays[_i];
              for (_j = 0, _len1 = buffers.length; _j < _len1; _j++) {
                obj = buffers[_j];
                arr.set(new Float32Array(obj.buffer), obj.startByte / 4);
              }
            }
            console.log(arr.subarray(12345, 12345 + 10));
          }
          return this.terminate();
        }
      };
      bufferArrays[nWorkers] = [];
      workers[nWorkers] = worker;
    }
    _results = [];
    for (index in workers) {
      worker = workers[index];
      blobs = blobArrays[worker.index];
      b = blobs.shift();
      _results.push(worker.postMessage(b));
    }
    return _results;
  };

  domReady = function() {
    var drop;
    drop = document.querySelector('.drop');
    drop.addEventListener('dragover', onDragOver, false);
    return drop.addEventListener('drop', onDrop, false);
  };

  window.addEventListener('DOMContentLoaded', domReady, false);

}).call(this);
