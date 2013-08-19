require 'open-uri'
require 'json'

query = "SELECT distinct subject_id FROM serengeti where species = 'zebra' and how_many > 10"

url = "https://the-zooniverse.cartodb.com/api/v2/sql?q="

query_url = URI::encode("#{url}#{query}")
data = open(query_url) { |f| f.read }

data = JSON.parse(data)['rows']

data.each do |row|
  subject_id = row['subject_id']
  `curl "www.snapshotserengeti.org/subjects/standard/#{subject_id}_0.jpg" -o #{subject_id}.jpg`
end

