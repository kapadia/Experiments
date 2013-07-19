require 'open-uri'

def create_field_url(run, rerun, camcol, field, band)
  
  # Adjust the run number if from Stripe 82 survey
  run = 100006 if run == 106
  run = 200006 if run == 206
  
  run_padded = "%06d" % run.to_i
  field_padded = "%04d" % field.to_i
  return "http://das.sdss.org/imaging/#{run}/#{rerun}/corr/#{camcol}/fpC-#{run_padded}-#{band}#{camcol}-#{field_padded}.fit.gz"
end

def montage_make_cutout(ra, dec, infile, outfile)
  
  s1 = 0.396127 # Natural scale of SDSS DR7
  s2 = 0.15 # Scale for galaxy zoo quench
  dimension = 424 # target cutout pixel dimension
  
  factor = s2 / s1
  fov_degrees = "%0.11f" % (s2 * dimension / 3600.0)
  `mSubimage #{infile} #{outfile} #{ra} #{dec} #{fov_degrees}`
  `mShrink #{outfile} #{outfile} #{factor}`
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
      outfile = File::join('cutouts', "#{objid}_#{band}.fits")
      
      `curl -o #{infile} '#{url}'` unless File.exists?(infile)
      montage_make_cutout(ra, dec, infile, outfile) unless File.exists?("#{outfile}")
    end
  end

end
