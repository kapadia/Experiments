# Get SDSS object ids
control = File.read("data/control.tab").split("\n").collect{ |row| row.split(/\s+/)[0] }
sample = File.read("data/sample.tab").split("\n").collect{ |row| row.split(/\s+/)[0] }

# Remove the first element, otherwise it will fuck up the query to CAS
control.shift()
sample.shift()
objids = control.concat(sample)

puts objids.count