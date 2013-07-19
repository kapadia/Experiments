require 'open-uri'

def create_field_url(run, rerun, camcol, field, band)
  
  # Adjust the run number if from Stripe 82 survey
  run = 100006 if run == 106
  run = 200006 if run == 206
  
  run_padded = "%06d" % run.to_i
  field_padded = "%04d" % field.to_i
  return "http://das.sdss.org/imaging/#{run}/#{rerun}/corr/#{camcol}/fpC-#{run_padded}-#{band}#{camcol}-#{field_padded}.fit.gz"
end

def montage_make_header(ra, dec)
  filename = File::join(File.dirname(__FILE__), 'header.tmp')
  
  # arcsec_per_pixel = 0.396127
  arcsec_per_pixel = 0.15
  dimension = 512
  
  fov_arcsec = arcsec_per_pixel * dimension
  fov_degrees = "%0.6f" % (fov_arcsec / 3600.0)
  
  mHdr = "mHdr -p #{arcsec_per_pixel} \"#{ra} #{dec}\" #{fov_degrees} #{filename}"
  `#{mHdr}`
end

def montage_make_cutout(ra, dec, infile, outfile)
  montage_make_header(ra, dec)
  
  `mProjectPP #{infile} #{outfile} header.tmp`
  
  `rm header.tmp`
  `rm #{outfile}_area.fits`
end

def montage_subimage(ra, dec, infile, outfile)
  arcsec_per_pixel = 0.15
  dimension = 424
  fov_arcsec = arcsec_per_pixel * dimension
  fov_degrees = "%0.11f" % (fov_arcsec / 3600.0)
  
  `mSubimage #{infile} #{outfile}.fits #{ra} #{dec} #{fov_degrees} #{fov_degrees}`
end

# Get SDSS object ids
objids = File.read("data/control.tab").split("\n").collect{ |row| row.split(/\s+/)[0] }
objids.concat File.read("data/sample.tab").split("\n").collect{ |row| row.split(/\s+/)[0] }
objids.shift()

while objids.count > 0
  
  query = "SELECT objid, run, rerun, camcol, field, ra, dec FROM galaxy WHERE objid in (#{objids.shift(10).join(',')})"
  query_url = URI::encode("http://cas.sdss.org/dr7/en/tools/search/x_sql.asp?format=csv&cmd=#{query}")
  
  data = open(query_url).read().split("\n").collect{ |row| row.split(',')}
  data.shift()
  data.each do |row|
    objid, run, rerun, camcol, field, ra, dec = row
    
    ['u', 'g', 'r', 'i', 'z'].each do |band|
      url = create_field_url(run, rerun, camcol, field, band)
      filename = url.split('/').last
      
      infile = File::join(File.dirname(__FILE__), 'FITS', filename)
      outfile = File::join('cutouts', "#{objid}_#{band}")
      
      `curl -o #{infile} '#{url}'` unless File.exists?(infile)
      montage_subimage(ra, dec, infile, outfile) unless File.exists?("#{outfile}.fits")
    end
  end

end
