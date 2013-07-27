
# GLSL Shaders
fragmentShaderSrc = """
  precision mediump float;
  
  void main(void) {
      gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
  }
"""

vertexShaderSrc = """
  attribute vec3 aVertexPosition;
  
  uniform mat4 uMVMatrix;
  uniform mat4 uPMatrix;
  
  void main(void) {
      gl_PointSize = 1.25;
      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  }
"""

# Scope variables
gl = null
program = null
mvMatrix = null
pMatrix = null
contourBuffer = null

viewportEl = null
sliderEl = null
canvases = []
selected = null

linspace = (start, stop, num) ->
  range = stop - start
  step = range / (num - 1)
  
  steps = new Float32Array(num)
  while num--
    steps[num] = start + num * step
  
  return steps

getContours = (e) ->
  
  # Reset selected because it's no longer selected
  selected = null
  
  # Get arguments
  arr = e.data.arr
  min = e.data.min
  max = e.data.max
  width = e.data.width
  height = e.data.height
  
  levels = parseInt sliderEl.val()
  z = linspace(min, max, levels)
  
  data = []
  for j in [0..height - 1]
    start = j * width
    data.push arr.subarray(start, start + width)
  
  # Set conrec arguments
  ilb = 0
  iub = data.length - 1
  jlb = 0
  jub = data[0].length - 1
  
  idx = new Uint16Array(data.length)
  jdx = new Uint16Array(data[0].length)
  
  i = j = 0
  while i < idx.length
    idx[i] = i + 1
    i += 1
  while j < jdx.length
    jdx[j] = j + 1
    j += 1
  
  # Juicy contours!
  conrec = new Conrec()
  conrec.contour(data, ilb, iub, jlb, jub, idx, jdx, z.length, z)
  c = conrec.contourList()
  
  # Enable slider
  sliderEl.removeAttr('disabled')
  console.log 'DONE'
  drawContours(c, width, height)

drawContour = (canvas, color, lineWidth) ->
  
  # Get dimensions from canvas
  width = canvas.width
  height = canvas.height
  
  # Clear canvas
  canvas.width = width
  
  context = canvas.getContext('2d')
  context.beginPath()
  
  context.strokeStyle = color
  
  # NOTE: Alpha value yields 1 when checking image data from canvas
  context.fillStyle = "rgba(0, 0, 0, 0.00625)"
  context.lineWidth = lineWidth
  context.translate(0.5 * width, 0.5 * height)
  context.rotate(-Math.PI / 2)
  context.translate(-0.5 * width, -0.5 * height)
  
  contour = canvas.contour
  
  # Move to the start of this contour
  context.moveTo(contour[0].x, contour[0].y)
  
  # Join the dots
  i = 1
  while i < contour.length
    context.lineTo contour[i].x, contour[i].y
    i += 1
  context.closePath()
  context.fill()
  context.stroke()

drawContours2 = (c, width, height) ->
  
  # Clean up old canvas
  while canvases.length
    viewportEl[0].removeChild(canvases.shift())
  
  l = 0
  while l < c.length
    
    # Create new canvas for each contour
    canvas = document.createElement('canvas')
    canvas.className = 'contour'
    canvas.width = width
    canvas.height = height
    canvases.push(canvas)
    viewportEl[0].insertBefore(canvas, viewportEl[0].firstChild)
    
    # Store contours on canvas
    canvas.contour = c[l]
    drawContour(canvas, "#FAFAFA", 1.5)
    l += 1

drawContours = (c, width, height) ->
  
  # Get length for buffer
  nVertices = 0
  for contour in c
    nVertices += contour.length
  
  gl.bindBuffer(gl.ARRAY_BUFFER, contourBuffer)
  
  vertices = new Float32Array(2 * nVertices)
  
  offset = 0
  for contour, j in c
    
    for point, i in contour
      index = 2 * i + offset
      vertices[index] = (2 / height) * point.y - 1
      vertices[index + 1] = (2 / width) * point.x - 1
    offset += 2 * contour.length
  
  gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)
  contourBuffer.itemSize = 2
  contourBuffer.numItems = nVertices
  
  gl.bindBuffer(gl.ARRAY_BUFFER, contourBuffer)
  gl.vertexAttribPointer(program.vertexPositionAttribute, contourBuffer.itemSize, gl.FLOAT, false, 0, 0)
  gl.drawArrays(gl.POINTS, 0, contourBuffer.numItems)


selectContour = (e) ->
  # TODO: Offset not available in Firefox
  x = e.offsetX
  y = e.offsetY
  
  # Deselect canvas
  if selected?
    canvas = canvases[selected]
    drawContour(canvas, "#FAFAFA", 1.5)
    $(canvas).removeClass('selected')
    $("canvas.contour").removeClass('deselect')
  
  # Check alpha channel in each canvas for selection using
  # while loop to preference deeper contours
  index = canvases.length
  while index--
    canvas = canvases[index]
    
    # TODO: Might need to cache this for performance (not sure)
    context = canvas.getContext('2d')
    imgData = context.getImageData(x, y, 1, 1)
    
    if imgData.data[3] is 1
      # Store index of selected contour
      selected = index
      
      # Specify selected canvas
      $(canvas).addClass("selected")
      
      # Deselect other canvases
      $("canvas.contour").not(".selected").addClass('deselect')
      
      # Redraw contour on canvas with selected color
      drawContour(canvas, "#00FF00", 2)
      break


domReady = ->
  console.log 'domReady'
  
  viewportEl = $("div.viewport")
  buttonEl = $('button[name="draw-contours"]')
  sliderEl = $('input[name="contour"]')
  
  new astro.FITS('lib/m101.fits', (fits) ->
    dataunit = fits.getDataUnit()
    
    dataunit.getFrame(0, (arr) ->
      width = dataunit.width
      height = dataunit.height
      
      # Update viewport width
      viewportEl.width(width)
      
      [min, max] = dataunit.getExtent(arr)
      
      # Set up WebFITS
      el = document.querySelector('.webfits')
      webfits = new astro.WebFITS(el, width)
      webfits.loadImage('radio', arr, width, height)
      webfits.setExtent(min, max)
      webfits.setImage('radio')
      webfits.setColorMap('gist_heat')
      
      # Pass array and precomputed extent
      buttonEl.on('click', {arr: arr, min: min, max: max, width: width, height: height}, getContours)
      sliderEl.on('mouseup', {arr: arr, min: min, max: max, width: width, height: height}, getContours)
      viewportEl.on('click', selectContour)
      
      # Create new canvas for WebGL instance
      canvas = document.createElement('canvas')
      canvas.className = 'contour'
      canvas.width = width
      canvas.height = height
      viewportEl[0].insertBefore(canvas, viewportEl[0].firstChild)
      gl = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
      
      gl.viewportWidth = width
      gl.viewportHeight = height
      
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
      
      contourBuffer = gl.createBuffer()
    )
  )


window.addEventListener('DOMContentLoaded', domReady, false)