


# Get min and max of array
getExtentAsync = (arr, nWorkers = 1) ->
  startTime = new Date()
  
  # Split array into nWorkers
  arrays = []
  
  subArrayLength = ~~(arr.length / nWorkers)
  i = nWorkers
  while i--
    startIndex = i * subArrayLength
    arrays.push arr.subarray(startIndex, startIndex + subArrayLength)
  
  # Define inline worker function
  onmessage = (e) ->

    arr = new Float32Array(e.data.arr)
    i = arr.length - 1
    min = max = arr[i]
    
    while i--
      value = arr[i]
      if value < min
        min = value
      if value > max
        max = value
    postMessage({min: min, max: max})
  
  # Trick to format function for worker when using CoffeeScript
  fn = onmessage.toString().replace('return postMessage', 'self.postMessage')
  fn = "onmessage = #{fn}"

  # Create URL for onmessage function used by worker
  onMessageBlob = new Blob([fn], {type: "application/javascript"})
  onMessageUrl = URL.createObjectURL(onMessageBlob)
  
  # Create storage for results of each worker
  mins = []
  maxs = []
  
  # Create workers
  workers = {}
  while nWorkers--
    worker = new Worker(onMessageUrl)
    worker.index = nWorkers
    
    # Define callback for when job is complete
    worker.onmessage = (e) ->
      data = e.data
      mins.push data.min
      maxs.push data.max
      
      # Pluck worker from array
      delete workers[@index]
      
      nRemainingWorkers = Object.keys(workers).length
      if nRemainingWorkers is 0
        min = Math.min.apply(Math, mins)
        max = Math.min.apply(Math, maxs)
        endTime = new Date()
        console.log 'workers', endTime - startTime
    
    workers[nWorkers] = worker
  
  # Start each worker
  for index, worker of workers
    array = arrays.shift()
    worker.postMessage({arr: array.buffer}, [array.buffer])

getExtent = (arr) ->
  
  i = arr.length - 1
  min = max = arr[i]
  
  while i--
    value = arr[i]
    if value < min
      min = value
    if value > max
      max = value
  return [min, max]

getHistogram = (arr, min, max, nBins) ->
  range = max - min
  dx = range / nBins
  
  h = new Uint16Array(nBins)
  
  for value, i in arr
    index = ~~(((value - min) / range) * nBins)
    if index is nBins
      console.log 'index', index, i
    h[index] += 1
  h.dx = dx
  return h
  
getData = ->
  size = 5000 * 5000
  # arr = []
  # for index in [0..size - 1]
  #   arr[index] = Math.random()
  arr = new Float32Array(size)
  for value, index in arr
    arr[index] = Math.random()
  return arr


domReady = ->
  
  arr = getData()
  
  [min, max] = getExtent(arr)
  histogram = getHistogram(arr, min, max, 50)
  
  formatCount = d3.format(",.0f")
  
  margin =
    top: 10
    right: 30
    bottom: 30
    left: 30
  
  width = 960 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom

  x = d3.scale.linear()
    .domain([0, 1])
    .range([0, width])

  y = d3.scale.linear()
    .domain([0, d3.max(histogram)])
    .range([height, 0])

  xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")

  svg = d3.select("body").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  bar = svg.selectAll(".bar")
      .data(histogram)
    .enter().append("g")
      .attr("class", "bar")
      .attr("transform", (d, i) -> return "translate(#{x(i * histogram.dx)}, #{y(d)})")

  bar.append("rect")
    .attr("x", 1)
    .attr("width", x(histogram.dx) - 1)
    .attr("height", (d) -> return height - y(d))
    
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0, #{height})")
    .call(xAxis);
  
  

window.addEventListener('DOMContentLoaded', domReady, false)