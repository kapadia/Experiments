
# Define some globals
gl = null
vShader = null
fShader = null
program = null
texture = null
textureCoordBuffer = null
buffer = null

mvMatrix = mat4.create()
mvMatrixStack = []
pMatrix = mat4.create()


initGL = (canvas) ->
  
  gl = canvas.getContext("webgl")
  gl.viewportWidth = canvas.width
  gl.viewportHeight = canvas.height
  gl.getExtension('OES_texture_float')
  
initShaders = ->
  
  fShader = gl.createShader(gl.FRAGMENT_SHADER)
  vShader = gl.createShader(gl.VERTEX_SHADER)
  
  gl.shaderSource(fShader, document.getElementById('shader-fs').textContent)
  gl.compileShader(fShader)
  
  gl.shaderSource(vShader, document.getElementById('shader-vs').textContent)
  gl.compileShader(vShader)
  
  program = gl.createProgram()
  gl.attachShader(program, vShader)
  gl.attachShader(program, fShader)
  gl.linkProgram(program)
  
  gl.useProgram(program)
  
  program.vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition")
  program.textureCoordAttribute = gl.getAttribLocation(program, "aTextureCoord")
  
  gl.enableVertexAttribArray(program.textureCoordAttribute)
  gl.enableVertexAttribArray(program.vertexPositionAttribute)
  
  program.pMatrixUniform = gl.getUniformLocation(program, "uPMatrix")
  program.mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix")
  program.samplerUniform = gl.getUniformLocation(program, "uSampler")
  
initBuffers = ->
  
  textureCoordBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, textureCoordBuffer)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    
    # Front face
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,

    # Back face
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,

    # Top face
    0.0, 1.0,
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    # Bottom face
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    1.0, 0.0,

    # Right face
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,

    # Left face
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0,
    
    ]),
    gl.STATIC_DRAW
  )
  
  buffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    
    # Front face
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    
    # Back face
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,
     
    # Top face
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
     
    # Bottom face
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,
    
    # Right face
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
     
    # Left face
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,
    
    ]),
    gl.STATIC_DRAW
  )
  
  
initTexture = ->
  
  texture = gl.createTexture()
  
  new astro.FITS('lib/L1448_13CO.fits', (fits) ->
    
    cube = fits.getDataUnit(0)
    width = cube.width
    height = cube.height
    depth = 2
    
    pixels = new Float32Array(width * height * depth)
    frame = 0
    cube.getFrames(0, depth, (arr) ->
      pixels.set(arr, width * height * frame)
      
      frame += 1
      if frame is depth
        loadTexture(texture, pixels, width, height * depth)
        draw()
    )
    
  )

loadTexture = (texture, arr, width, height) ->
  
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE, width, height, 0, gl.LUMINANCE, gl.FLOAT, arr)
  
  gl.bindTexture(gl.TEXTURE_2D, null)


degToRad = (deg) ->
  return deg * Math.PI / 180

draw = ->
  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
  
  mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix)
  
  mat4.identity(mvMatrix)
  
  # mat4.translate(mvMatrix, [1.0, 0.0, 0.0], mvMatrix)
  
  # mat4.rotate(mvMatrix, mvMatrix, degToRad(xRot), [1, 0, 0])
  # mat4.rotate(mvMatrix, mvMatrix, degToRad(yRot), [0, 1, 0])
  # mat4.rotate(mvMatrix, mvMatrix, degToRad(zRot), [0, 0, 1])
  
  gl.bindBuffer(gl.ARRAY_BUFFER, textureCoordBuffer)
  
  gl.vertexAttribPointer(program.textureCoordAttribute, 2, gl.FLOAT, false, 0, 0)
  gl.vertexAttribPointer(program.vertexPositionAttribute, 2, gl.FLOAT, false, 0, 0)
  
  gl.activeTexture(gl.TEXTURE0)
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.uniform1i(program.samplerUniform, 0)
  
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  
  gl.uniformMatrix4fv(program.pMatrixUniform, false, pMatrix)
  gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix)
  
  gl.drawArrays(gl.TRIANGLES, 0, 6)
  
  
domReady = ->
  
  canvas = document.getElementById('volumetric')
  initGL(canvas)
  initShaders()
  initBuffers()
  initTexture()
  
  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE)
  gl.enable(gl.BLEND)
  gl.enable(gl.DEPTH_TEST)


window.addEventListener('DOMContentLoaded', domReady, false)