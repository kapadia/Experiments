
# GLSL Shaders
fragmentShaderSrc = """
  precision mediump float;
  
  void main(void) {
      gl_FragColor = vec4(0.0, 0.4431, 0.8980, 1.0);
  }
"""

vertexShaderSrc = """
  attribute vec3 aVertexPosition;
  
  uniform mat4 uMVMatrix;
  uniform mat4 uPMatrix;
  
  void main(void) {
      gl_PointSize = 1.0;
      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  }
"""

# Scope variables
dropEl = null

gl = null
program = null
mvMatrix = null
pMatrix = null
plotBuffer = null

onDragOver = (e) ->
  e.stopPropagation()
  e.preventDefault()

onDrop = (e) ->
  e.stopPropagation()
  e.preventDefault()
  
  window.removeEventListener('dragover', onDragOver, false)
  window.removeEventListener('drop', onDrop, false)
  
  f = e.dataTransfer.files[0]
  
  new astro.FITS(f, (fits) ->
    table = fits.getDataUnit()
    table.rows;
    
    table.getRows(0, table.rows, (rows) ->
      scatter(rows)
    )
  )


scatter = (data) ->
  console.log 'scatter'
  gl.bindBuffer(gl.ARRAY_BUFFER, plotBuffer)
  
  nVertices = data.length
  vertices = new Float32Array(2 * nVertices)
  
  key1 = 'wavelength'
  key2 = 'flux'
  # key1 = 'XFOCAL'
  # key2 = 'YFOCAL'
  
  # Get the minimum and maximum for each column
  i = data.length
  min1 = max1 = data[i - 1][key1]
  min2 = max2 = data[i - 1][key2]
  while i--
    val1 = data[i][key1]
    val2 = data[i][key2]
    
    min1 = val1 if val1 < min1
    max1 = val1 if val1 > max1
    
    min2 = val2 if val2 < min2
    max2 = val2 if val2 > max2
  
  range1 = max1 - min1
  range2 = max2 - min2
  
  for datum, index in data
    i = 2 * index
    val1 = datum[key1]
    val2 = datum[key2]
    
    vertices[i] = (2 / range1) * (val1 - min1) - 1
    vertices[i + 1] = (2 / range2) * (val2 - min2) - 1
  
  gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)
  plotBuffer.itemSize = 2
  plotBuffer.numItems = nVertices
  
  gl.bindBuffer(gl.ARRAY_BUFFER, plotBuffer)
  gl.vertexAttribPointer(program.vertexPositionAttribute, plotBuffer.itemSize, gl.FLOAT, false, 0, 0)
  gl.drawArrays(gl.POINTS, 0, plotBuffer.numItems)


domReady = ->
  console.log 'domReady'
  
  dropEl = document.querySelector('body')
  
  # Listen for drop events
  dropEl.addEventListener('dragover', onDragOver, false)
  dropEl.addEventListener('drop', onDrop, false)
  
  # Create new canvas for WebGL instance
  canvas = document.querySelector('canvas.plot')
  gl = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
  
  gl.viewportWidth = canvas.width
  gl.viewportHeight = canvas.height
  
  # Set up shaders
  vertexShader = gl.createShader(gl.VERTEX_SHADER)
  fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
  
  gl.shaderSource(vertexShader, vertexShaderSrc)
  gl.compileShader(vertexShader)
  
  gl.shaderSource(fragmentShader, fragmentShaderSrc)
  gl.compileShader(fragmentShader)
  
  # Create program
  program = gl.createProgram()
  gl.attachShader(program, vertexShader)
  gl.attachShader(program, fragmentShader)
  gl.linkProgram(program)
  
  gl.useProgram(program)
  
  program.vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition")
  gl.enableVertexAttribArray(program.vertexPositionAttribute)
  
  program.pMatrixUniform = gl.getUniformLocation(program, "uPMatrix")
  program.mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix")
  
  mvMatrix = mat4.create()
  pMatrix = mat4.create()
  
  mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix)
  mat4.identity(mvMatrix)
  gl.uniformMatrix4fv(program.pMatrixUniform, false, pMatrix)
  gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix)
  
  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
  
  plotBuffer = gl.createBuffer()


window.addEventListener('DOMContentLoaded', domReady, false)