
DOMReady = ->
  # url = "http://radio.galaxyzoo.org.s3.amazonaws.com/S74_radio.fits.gz"
  url = "http://s3.amazonaws.com/radio.galaxyzoo.org/beta/subjects/raw/S1083.fits.gz"
  
  new astro.FITS(url, (f) ->
    console.log f
  )
  
  # xhr = new XMLHttpRequest()
  # xhr.open('GET', url)
  # xhr.responseType = 'arraybuffer'
  # xhr.overrideMimeType("application/json")
  # xhr.onload = ->
  #   console.log xhr.response
  # xhr.send()

window.addEventListener('DOMContentLoaded', DOMReady, false)