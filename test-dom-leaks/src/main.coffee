
DOMReady = ->
  
  button = document.querySelector('button')
  button.onclick = (e) ->
    
    # Add 100 canvas elements
    # NOTE: This adds 100 nodes to the DOM, which are not cleared when the function looses scope.
    for i in [0..99]
      canvas = document.createElement('canvas')
    
    # # NOTE: This adds nodes and does not remove them either ...
    # for i in [0..99]
    #   canvas = document.createElement('canvas')
    #   canvas = null
    
    # for i in [0..99]
    #   canvas = document.createElement('canvas')
    #   document.body.appendChild(canvas)
    #   canvas = null
    # 
    # canvases = document.querySelectorAll('canvas')
    # for canvas in canvases
    #   document.body.removeChild(canvas)


window.addEventListener('DOMContentLoaded', DOMReady, false)