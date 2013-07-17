
TWOGIGS = 2147483648
ONEGIG = 1073741824
HALFGIG = 536870912

AMOUNT = ONEGIG

allocateOnce = ->
  console.log 'allocateOnce'
  
  # Get the number of elements for float 32 array
  nElements = AMOUNT / 4
  arr = new Float32Array(nElements)
  while nElements--
    arr[nElements] = Math.random()


DOMReady = ->
  
  # Test different cases of memory allocation
  
  sT = new Date()
  arr = allocateOnce()
  fT = new Date()
  
  console.log fT - sT
  
window.addEventListener('DOMContentLoaded', DOMReady, false)