// Generated by CoffeeScript 1.6.3
(function() {
  var canvases, contourBuffer, domReady, drawContour, drawContours, drawContours2, fragmentShaderSrc, getContours, gl, linspace, mvMatrix, pMatrix, program, selectContour, selected, sliderEl, vertexShaderSrc, viewportEl;

  fragmentShaderSrc = "precision mediump float;\n\nvoid main(void) {\n    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);\n}";

  vertexShaderSrc = "attribute vec3 aVertexPosition;\n\nuniform mat4 uMVMatrix;\nuniform mat4 uPMatrix;\n\nvoid main(void) {\n    gl_PointSize = 1.25;\n    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n}";

  gl = null;

  program = null;

  mvMatrix = null;

  pMatrix = null;

  contourBuffer = null;

  viewportEl = null;

  sliderEl = null;

  canvases = [];

  selected = null;

  linspace = function(start, stop, num) {
    var range, step, steps;
    range = stop - start;
    step = range / (num - 1);
    steps = new Float32Array(num);
    while (num--) {
      steps[num] = start + num * step;
    }
    return steps;
  };

  getContours = function(e) {
    var arr, c, conrec, data, height, i, idx, ilb, iub, j, jdx, jlb, jub, levels, max, min, start, width, z, _i, _ref;
    selected = null;
    arr = e.data.arr;
    min = e.data.min;
    max = e.data.max;
    width = e.data.width;
    height = e.data.height;
    levels = parseInt(sliderEl.val());
    z = linspace(min, max, levels);
    data = [];
    for (j = _i = 0, _ref = height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; j = 0 <= _ref ? ++_i : --_i) {
      start = j * width;
      data.push(arr.subarray(start, start + width));
    }
    ilb = 0;
    iub = data.length - 1;
    jlb = 0;
    jub = data[0].length - 1;
    idx = new Uint16Array(data.length);
    jdx = new Uint16Array(data[0].length);
    i = j = 0;
    while (i < idx.length) {
      idx[i] = i + 1;
      i += 1;
    }
    while (j < jdx.length) {
      jdx[j] = j + 1;
      j += 1;
    }
    conrec = new Conrec();
    conrec.contour(data, ilb, iub, jlb, jub, idx, jdx, z.length, z);
    c = conrec.contourList();
    sliderEl.removeAttr('disabled');
    console.log('DONE');
    return drawContours(c, width, height);
  };

  drawContour = function(canvas, color, lineWidth) {
    var context, contour, height, i, width;
    width = canvas.width;
    height = canvas.height;
    canvas.width = width;
    context = canvas.getContext('2d');
    context.beginPath();
    context.strokeStyle = color;
    context.fillStyle = "rgba(0, 0, 0, 0.00625)";
    context.lineWidth = lineWidth;
    context.translate(0.5 * width, 0.5 * height);
    context.rotate(-Math.PI / 2);
    context.translate(-0.5 * width, -0.5 * height);
    contour = canvas.contour;
    context.moveTo(contour[0].x, contour[0].y);
    i = 1;
    while (i < contour.length) {
      context.lineTo(contour[i].x, contour[i].y);
      i += 1;
    }
    context.closePath();
    context.fill();
    return context.stroke();
  };

  drawContours2 = function(c, width, height) {
    var canvas, l, _results;
    while (canvases.length) {
      viewportEl[0].removeChild(canvases.shift());
    }
    l = 0;
    _results = [];
    while (l < c.length) {
      canvas = document.createElement('canvas');
      canvas.className = 'contour';
      canvas.width = width;
      canvas.height = height;
      canvases.push(canvas);
      viewportEl[0].insertBefore(canvas, viewportEl[0].firstChild);
      canvas.contour = c[l];
      drawContour(canvas, "#FAFAFA", 1.5);
      _results.push(l += 1);
    }
    return _results;
  };

  drawContours = function(c, width, height) {
    var contour, i, index, j, nVertices, offset, point, vertices, _i, _j, _k, _len, _len1, _len2;
    nVertices = 0;
    for (_i = 0, _len = c.length; _i < _len; _i++) {
      contour = c[_i];
      nVertices += contour.length;
    }
    gl.bindBuffer(gl.ARRAY_BUFFER, contourBuffer);
    vertices = new Float32Array(2 * nVertices);
    offset = 0;
    for (j = _j = 0, _len1 = c.length; _j < _len1; j = ++_j) {
      contour = c[j];
      for (i = _k = 0, _len2 = contour.length; _k < _len2; i = ++_k) {
        point = contour[i];
        index = 2 * i + offset;
        vertices[index] = (2 / height) * point.y - 1;
        vertices[index + 1] = (2 / width) * point.x - 1;
      }
      offset += 2 * contour.length;
    }
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
    contourBuffer.itemSize = 2;
    contourBuffer.numItems = nVertices;
    gl.bindBuffer(gl.ARRAY_BUFFER, contourBuffer);
    gl.vertexAttribPointer(program.vertexPositionAttribute, contourBuffer.itemSize, gl.FLOAT, false, 0, 0);
    return gl.drawArrays(gl.POINTS, 0, contourBuffer.numItems);
  };

  selectContour = function(e) {
    var canvas, context, imgData, index, x, y, _results;
    x = e.offsetX;
    y = e.offsetY;
    if (selected != null) {
      canvas = canvases[selected];
      drawContour(canvas, "#FAFAFA", 1.5);
      $(canvas).removeClass('selected');
      $("canvas.contour").removeClass('deselect');
    }
    index = canvases.length;
    _results = [];
    while (index--) {
      canvas = canvases[index];
      context = canvas.getContext('2d');
      imgData = context.getImageData(x, y, 1, 1);
      if (imgData.data[3] === 1) {
        selected = index;
        $(canvas).addClass("selected");
        $("canvas.contour").not(".selected").addClass('deselect');
        drawContour(canvas, "#00FF00", 2);
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  domReady = function() {
    var buttonEl;
    console.log('domReady');
    viewportEl = $("div.viewport");
    buttonEl = $('button[name="draw-contours"]');
    sliderEl = $('input[name="contour"]');
    return new astro.FITS('lib/m101.fits', function(fits) {
      var dataunit;
      dataunit = fits.getDataUnit();
      return dataunit.getFrame(0, function(arr) {
        var canvas, el, fragmentShader, height, max, min, vertexShader, webfits, width, _ref;
        width = dataunit.width;
        height = dataunit.height;
        viewportEl.width(width);
        _ref = dataunit.getExtent(arr), min = _ref[0], max = _ref[1];
        el = document.querySelector('.webfits');
        webfits = new astro.WebFITS(el, width);
        webfits.loadImage('radio', arr, width, height);
        webfits.setExtent(min, max);
        webfits.setImage('radio');
        webfits.setColorMap('gist_heat');
        buttonEl.on('click', {
          arr: arr,
          min: min,
          max: max,
          width: width,
          height: height
        }, getContours);
        sliderEl.on('mouseup', {
          arr: arr,
          min: min,
          max: max,
          width: width,
          height: height
        }, getContours);
        viewportEl.on('click', selectContour);
        canvas = document.createElement('canvas');
        canvas.className = 'contour';
        canvas.width = width;
        canvas.height = height;
        viewportEl[0].insertBefore(canvas, viewportEl[0].firstChild);
        gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
        gl.viewportWidth = width;
        gl.viewportHeight = height;
        vertexShader = gl.createShader(gl.VERTEX_SHADER);
        fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(vertexShader, vertexShaderSrc);
        gl.compileShader(vertexShader);
        gl.shaderSource(fragmentShader, fragmentShaderSrc);
        gl.compileShader(fragmentShader);
        program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);
        gl.useProgram(program);
        program.vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition");
        gl.enableVertexAttribArray(program.vertexPositionAttribute);
        program.pMatrixUniform = gl.getUniformLocation(program, "uPMatrix");
        program.mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix");
        mvMatrix = mat4.create();
        pMatrix = mat4.create();
        mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);
        mat4.identity(mvMatrix);
        gl.uniformMatrix4fv(program.pMatrixUniform, false, pMatrix);
        gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix);
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        return contourBuffer = gl.createBuffer();
      });
    });
  };

  window.addEventListener('DOMContentLoaded', domReady, false);

}).call(this);
