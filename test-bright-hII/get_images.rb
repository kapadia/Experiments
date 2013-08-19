require 'open-uri'
require 'json'
require 'csv'

# data_url = "http://www.atnf.csiro.au/research/multibeam/HIPASS-BGC/Koribalski.BGC.machine.table"
path = File::join('.', 'Koribalski.BGC.machine.table.txt')
data = open(path) { |f| f.read }


data = data.split(/(-{4,}|={4,})/).last

data = CSV.parse(data, { :col_sep => "\t" })
puts data[1][1]


# # data = open(query_url).read().split("\n").collect{ |row| row.split(',')}
# 
# data = data.split("\n").collect{ |row| row.split(/\s{2,}/) }
# puts data[1]
# # data.each do |row|
# #   puts row[0]
# # end
