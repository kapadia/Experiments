
domReady = ->
  console.log 'domReady'
  
  new astro.FITS('lib/m101.fits', (fits) ->
    dataunit = fits.getDataUnit()
    
    dataunit.getFrame(0, (arr) ->
      width = dataunit.width
      height = dataunit.height
      
      data = []
      for j in [0..height - 1]
        row = []
        for i in [0..width - 1]
          index = j * width + i
          row.push arr[index]
        
        data.push row
      
      # Try contours
      z = [2396, 10332, 18267 ,26203]
      # z = [2300, 2400, 2500, 2600, 26000]
      conrec = new Conrec()
      conrec.contour(data, 0, data.length - 1, 0, data[0].length - 1, [data.length], [data[0].length], z.length, z)
      c = conrec.contourList()
      
      console.log(c)
    )
  )


window.addEventListener('DOMContentLoaded', domReady, false)