

go = ->
  console.log 'go'
  # Create large typed array
  size = 536870912
  nElements = 4194304
  
  arr = new Float32Array(size / 4)
  
  # Create 32 sub arrays with 4194304 elements
  subarrays = []
  i = j = 32
  while i--
    subarray = new Float32Array(nElements)
    for value, index in subarray
      subarray[index] = Math.random()
    subarrays.push(subarray)
  
  # Attempt to bombard the main array with all 32 subarrays
  while j--
    do (j) ->
      setTimeout ( ->
        arr.set(subarrays[j], j * nElements)
        delete subarrays[j]
        if j is 0
          console.log arr[0], subarrays
      ), 500

domReady = ->
  button = document.querySelector('h4')
  button.onclick = (e) ->
    go()

window.addEventListener('DOMContentLoaded', domReady, false)