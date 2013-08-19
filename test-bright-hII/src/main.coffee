
ruse = null
xEl = yEl = null
data = null
esoButton = null

onAxis = ->
  
  x = xEl.value
  y = yEl.value
  
  points = data.map( (d) ->
    datum = {}
    datum[x] = Math.log parseFloat d[x]
    datum[y] = Math.log parseFloat d[y]
    
    return datum
  )
  
  ruse.plot(points)


DOMReady = ->
  console.log 'DOMReady'
  
  el = document.querySelector("#ruse")
  xEl = document.querySelector("select.x-axis")
  yEl = document.querySelector("select.y-axis")
  esoButtonEl = document.querySelector('button.eso149')
  
  ruse = new astro.Ruse(el, 800, 480)
  
  $.ajax("Koribalski.BGC.machine.json")
    .done( (d) ->
      data = d
      
      xEl.onchange = onAxis
      yEl.onchange = onAxis
      
      xEl.value = 'ra'
      yEl.value = 'dec'
      onAxis()
    )


window.addEventListener('DOMContentLoaded', DOMReady, false)