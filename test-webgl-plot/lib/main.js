// Generated by CoffeeScript 1.6.3
(function() {
  var domReady, drag, dropEl, fragmentShaderSrc, gl, mvMatrix, onDragOver, onDrop, pMatrix, plotBuffer, program, rotationMatrix, scatter, toRadians, vertexShaderSrc, xOldOffset, yOldOffset, _setupMouseControls;

  fragmentShaderSrc = "precision mediump float;\n\nvoid main(void) {\n    gl_FragColor = vec4(0.0, 0.4431, 0.8980, 1.0);\n}";

  vertexShaderSrc = "attribute vec3 aVertexPosition;\n\nuniform mat4 uMVMatrix;\nuniform mat4 uPMatrix;\n\nvoid main(void) {\n    gl_PointSize = 1.25;\n    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n}";

  dropEl = null;

  gl = null;

  program = null;

  mvMatrix = null;

  pMatrix = null;

  rotationMatrix = null;

  plotBuffer = null;

  drag = false;

  xOldOffset = null;

  yOldOffset = null;

  onDragOver = function(e) {
    e.stopPropagation();
    return e.preventDefault();
  };

  onDrop = function(e) {
    var f;
    e.stopPropagation();
    e.preventDefault();
    window.removeEventListener('dragover', onDragOver, false);
    window.removeEventListener('drop', onDrop, false);
    f = e.dataTransfer.files[0];
    return new astro.FITS(f, function(fits) {
      var table;
      table = fits.getDataUnit();
      table.rows;
      console.log(table.columns);
      return table.getRows(0, table.rows, function(rows) {
        return scatter(rows);
      });
    });
  };

  toRadians = function(deg) {
    return deg * 0.017453292519943295;
  };

  _setupMouseControls = function() {
    var _this = this;
    this.canvas.onmousedown = function(e) {
      drag = true;
      xOldOffset = e.clientX;
      return yOldOffset = e.clientY;
    };
    this.canvas.onmouseup = function(e) {
      return drag = false;
    };
    this.canvas.onmousemove = function(e) {
      var deltaX, deltaY, x, y;
      if (!drag) {
        return;
      }
      x = e.clientX;
      y = e.clientY;
      deltaX = x - xOldOffset;
      deltaY = y - yOldOffset;
      rotationMatrix = mat4.create();
      mat4.identity(rotationMatrix);
      mat4.rotateY(rotationMatrix, rotationMatrix, _this.toRadians(deltaX / 4));
      mat4.rotateX(rotationMatrix, rotationMatrix, _this.toRadians(deltaY / 4));
      mat4.multiply(_this.rotationMatrix, rotationMatrix, _this.rotationMatrix);
      xOldOffset = x;
      yOldOffset = y;
      return draw();
    };
    this.canvas.onmouseout = function(e) {
      return drag = false;
    };
    return this.canvas.onmouseover = function(e) {
      return drag = false;
    };
  };

  scatter = function(data) {
    var datum, i, index, key1, key2, max1, max2, min1, min2, nVertices, range1, range2, val1, val2, vertices, _i, _len;
    console.log('scatter');
    gl.bindBuffer(gl.ARRAY_BUFFER, plotBuffer);
    nVertices = data.length;
    vertices = new Float32Array(2 * nVertices);
    key1 = 'RACEN';
    key2 = 'DECCEN';
    i = data.length;
    min1 = max1 = data[i - 1][key1];
    min2 = max2 = data[i - 1][key2];
    while (i--) {
      val1 = data[i][key1];
      val2 = data[i][key2];
      if (val1 < min1) {
        min1 = val1;
      }
      if (val1 > max1) {
        max1 = val1;
      }
      if (val2 < min2) {
        min2 = val2;
      }
      if (val2 > max2) {
        max2 = val2;
      }
    }
    range1 = max1 - min1;
    range2 = max2 - min2;
    for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
      datum = data[index];
      i = 2 * index;
      val1 = datum[key1];
      val2 = datum[key2];
      vertices[i] = (2 / range1) * (val1 - min1) - 1;
      vertices[i + 1] = (2 / range2) * (val2 - min2) - 1;
    }
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
    plotBuffer.itemSize = 2;
    plotBuffer.numItems = nVertices;
    gl.bindBuffer(gl.ARRAY_BUFFER, plotBuffer);
    gl.vertexAttribPointer(program.vertexPositionAttribute, plotBuffer.itemSize, gl.FLOAT, false, 0, 0);
    return gl.drawArrays(gl.POINTS, 0, plotBuffer.numItems);
  };

  domReady = function() {
    var canvas, fragmentShader, vertexShader;
    console.log('domReady');
    dropEl = document.querySelector('body');
    dropEl.addEventListener('dragover', onDragOver, false);
    dropEl.addEventListener('drop', onDrop, false);
    canvas = document.querySelector('canvas.plot');
    canvas.width = 600;
    canvas.height = 400;
    gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
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
    rotationMatrix = mat4.create();
    mat4.perspective(45, canvas.width / canvas.height, 0.1, 100.0, pMatrix);
    mat4.identity(rotationMatrix);
    mat4.identity(mvMatrix);
    gl.uniformMatrix4fv(program.pMatrixUniform, false, pMatrix);
    gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix);
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    return plotBuffer = gl.createBuffer();
  };

  window.addEventListener('DOMContentLoaded', domReady, false);

}).call(this);
