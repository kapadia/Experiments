

# Define a function to be passed to Worker
multiplyBy2 = (arr) ->
  
  # Just for kicks, multiply each element by 2
  for value, index in arr
    arr[index] = 2 * value
  
  return arr

go = (e) ->
  
  # Suppose we have a large array
  arr = new Float32Array(10000000)
  for value, index in arr
    arr[index] = Math.random()
  
  # Define function to be executed on worker
  onmessage = (e) ->
    
    # Get the function url and array
    fnUrl = e.data.fnUrl
    arr = e.data.arr
    
    # Import the function
    importScripts(fnUrl)
    
    # Call the function
    multiplyBy2(arr) for i in [1..10000]
    data = multiplyBy2(arr)
    postMessage(data)
  
  # Since functions cannot be passed to workers, we do a clever trick
  # to pass the function. String formatting needed because of CoffeeScript
  # compilation.
  fn1 = onmessage.toString().replace('return postMessage(data);', 'postMessage(data);')
  fn1 = "onmessage = #{fn1}"
  
  fn2 = multiplyBy2.toString()
  fn2 = "multiplyBy2 = #{fn2}"
  
  mime = "application/javascript"
  blob1 = new Blob([fn1], {type: mime})
  blob2 = new Blob([fn2], {type: mime})
  url1 = URL.createObjectURL(blob1)
  url2 = URL.createObjectURL(blob2)
  
  # Initialize a Web Worker with URL to file with JS to be executed
  worker = new Worker(url1)
  
  # Define the callback for when task is complete
  worker.onmessage = (e) ->
    data = e.data
    
    console.log 'done'
    
    # Clean up urls and worker
    URL.revokeObjectURL(url1)
    URL.revokeObjectURL(url2)
    worker.terminate()
  
  # Send data to worker
  worker.postMessage({fnUrl: url2, arr: arr})




document.addEventListener('DOMContentLoaded', ->
  go() for i in [1...8]
, false)