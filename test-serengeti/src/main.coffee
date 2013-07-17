imgStack = []
rows = null
imgPointer = 0
canvas = null
context = null
isPlaying = false
id = null
progressEl = null
infoEl = null
siteCodeEl = null


updateProgress = ->
  width = 600
  progress = width * ( imgPointer / (imgStack.length - 1) )
  progressEl.css('width', progress)

drawImage = (src) ->
  img = new Image()
  img.onload = (e) ->
    context.drawImage(img, 0, 0)
  img.src = src

previous = ->
  return false if imgStack.length is 0
  return false if imgPointer is 0
  imgPointer -= 1
  drawImage( imgStack[imgPointer] )
  updateProgress()
  return true

next = ->
  return false if imgStack.length is 0
  return false if imgPointer is (imgStack.length - 1)
  imgPointer += 1
  
  siteCodeEl.text(rows[imgPointer].site_code)
  infoEl.text( rows[imgPointer].imgurl )
  
  drawImage( imgStack[imgPointer] )
  updateProgress()
  return true
  
pause = ->
  return if id is null
  
  isPlaying = false
  clearInterval(id)
  id = null

getQuery = (query) ->
  url = encodeURI "https://aliburchard.cartodb.com/api/v2/sql?q=#{query}"
  return url.replace(/\+/g, '%2B')

getData = (url) ->
  $.ajax(url)
    .done( (data) ->
      
      # Reset image pointer
      imgPointer = 0
      infoEl.text('')
      
      # Clear canvas
      canvas.width = canvas.width
      
      rows = data.rows
      imgStack = rows.map( (d) -> return d.imgurl )
      updateProgress()
      
      # Check if query returned images
      if imgStack.length is 0
        infoEl.text("No images.")
        return
      
      drawImage( imgStack[ imgPointer ] )
    )

DOMReady = ->
  
  canvas = document.querySelector('#flipbook')
  context = canvas.getContext('2d')
  progressEl = $('div.progress')
  infoEl = $("p.info")
  siteCodeEl = $("p.site-code")
  
  filters =
    species: ''
    site: ''
  
  # Filter callbacks
  $("select[data-filter='species']").on('change', (e) ->
    pause()
    
    value = e.target.value
    return if value is ''
    filters.species = value
    
    if filters.site is ''
      query = "SELECT * FROM ss_cons_coords WHERE species ILIKE '%#{filters.species}%' ORDER BY timestamp_proc"
    
    else
      query = "SELECT * FROM ss_cons_coords WHERE species ILIKE '%#{filters.species}%' AND site_code = '#{filters.site}' ORDER BY timestamp_proc"
    
    url = getQuery(query)
    getData(url)
    
  )
  
  $("select[data-filter='site']").on('change', (e) ->
    pause()
    
    value = e.target.value
    return if value is ''
    filters.site = value
    
    if filters.species is ''
      # Query only by site
      query = "SELECT * FROM ss_cons_coords WHERE site_code = '#{filters.site}' ORDER BY timestamp_proc"
      
    else
      # Query by site and species
      query = "SELECT * FROM ss_cons_coords WHERE species ILIKE '%#{filters.species}%' AND site_code = '#{filters.site}' ORDER BY timestamp_proc"
    
    url = getQuery(query)
    getData(url)
  )
  
  # Button callbacks
  $("button.prev").on('click', previous)
  $("button.next").on('click', next)
  $("button.reset").on('click', (e) ->
    imgPointer = 0
    drawImage( imgStack[ imgPointer ] )
    updateProgress()
  )
  $("button.pause").on('click', pause)
  $("button.play").on('click', (e) ->
    return if isPlaying
    
    isPlaying = true
    id = setInterval ( ->
      unless next()
        clearInterval(id)
        isPlaying = false
    ), 50
    
  )


window.addEventListener('DOMContentLoaded', DOMReady, false)