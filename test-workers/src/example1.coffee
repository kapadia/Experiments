

go = (e) ->
  
  # Define function to be executed on worker
  onmessage = (e) ->
    arr = [1, 2, 3, 4]
    data =
      arr: [1, 2, 3, 4]
      string: "#{e.data.str}, yea we did!"
    postMessage(data)
  
  # Since functions cannot be passed to workers, we do a clever trick. 
  # String formatting needed because of CoffeeScript compilation.
  fn = onmessage.toString().replace('return postMessage(data);', 'postMessage(data);')
  fn = "onmessage = #{fn}"
  
  mime = "application/javascript"
  blob = new Blob([fn], {type: mime}
  url = URL.createObjectURL(blob)
  
  # Initialize a Web Worker with URL to file with JS to be executed
  worker = new Worker(url)
  
  # Define the callback for when task is complete
  worker.onmessage = (e) ->
    data = e.data
    
    console.log data
    
    # Clean up Blob url and worker
    URL.revokeObjectURL(url)
    worker.terminate()
  
  # Send data to worker
  worker.postMessage({str: 'this is a string we pass to the worker'})

document.addEventListener('DOMContentLoaded', go, false)