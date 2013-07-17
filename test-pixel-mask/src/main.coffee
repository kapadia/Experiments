
canvas = null
context = null
counter = null
maxSubjects = 1000
window.maskValues = []


isSimulation = (subject) ->
  return if subject.metadata.training[0].type is 'empty' then false else true

getSubjects = ->
  $.ajax("https://api.zooniverse.org/projects/spacewarp/groups/5154a3783ae74086ab000002/subjects?limit=10")
    .done( (subjects) ->
      counter = subjects.length - 1
      
      checkMask = (subject) ->
        
        if isSimulation(subject)
          metadata = subject.metadata.training[0]
          x = metadata.x
          y = metadata.y
          
          xhr = new XMLHttpRequest()
          xhr.open('GET', subject.location.standard)
          xhr.responseType = 'blob'
          xhr.onload = ->
            url = window.URL.createObjectURL(xhr.response)
            
            img = new Image()
            img.onload = (e) ->
              canvas.width = img.width
              canvas.height = img.height
              context.drawImage(img, 0, 0)
              
              pixel = context.getImageData(x, img.height - y, 1, 1)
              maskValues.push pixel.data[3]
              
              # Move on to the next image
              counter -= 1
              maxSubjects -= 1
              
              if counter is 0
                getSubjects() if maxSubjects > 0
                return
              
              checkMask( subjects[counter] )
            img.src = url
          xhr.send()
        else
          
          # Move on to the next image
          counter -= 1
          maxSubjects -= 1
          
          if counter is 0
            getSubjects() if maxSubjects > 0
            return
          checkMask( subjects[counter] )
      
      checkMask( subjects[counter] )
    )


DOMReady = ->
  console.log 'DOMReady'
  
  # Create offscreen canvas
  canvas = document.querySelector('canvas')
  context = canvas.getContext('2d')
  
  getSubjects()

window.addEventListener('DOMContentLoaded', DOMReady, false)