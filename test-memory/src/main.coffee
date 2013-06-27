

class AllocateArray

  constructor: ->
    @chunks = []
    
    for i in [0..19]
      
      # Allocates 50 MB (13107200 elements of 4 bytes each)
      @chunks.push new Float32Array(13107200)
    
    # At this point 1000 MB have been allocated.
    console.log @chunks


class AllocateBuffer
  
  # Number of bytes in 512 MB
  bytes: 536870912
  
  
  constructor: ->
    @buffer = new ArrayBuffer(@bytes)

# Wrapping object initialization in yet another function
# This should definately trigger garbage collection
init = ->
  console.log 'init'
  a2 = new AllocateBuffer()

# This should be null
init()