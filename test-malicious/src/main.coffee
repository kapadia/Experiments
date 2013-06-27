

class Allocate

  constructor: ->
    @chunks = []
    
    for i in [0..19]
      
      # Allocates 50 MB (13107200 elements of 4 bytes each)
      @chunks.push new Float32Array(13107200)
    
    # At this point 1000 MB have been allocated.
    console.log @chunks


class GPUHack
  dimension: 4096
  
  constructor: ->
    console.log 'GPUHack'
    
    # canvas = document.querySelector("canvas")
    # @ctx = canvas.getContext("experimental-webgl")
    
    el = document.querySelector('#container')
    @webfits = new astro.WebFITS(el, @dimension)
  
  overloadTexture: ->
    for i in [0..15]
      arr = new Float32Array(@dimension * @dimension)
      @webfits.loadImage("fake-data-#{i}", arr, @dimension, 1)

gpuHack = new GPUHack()

setTimeout ( ->
  gpuHack.overloadTexture()
), 500

# setTimeout ( ->
#   gpuHack.overloadTexture()
# ), 5000