from astropy.io import ascii
from astropy.coordinates import Angle
import json

def ascii2json():
  """Machine readable ascii to json for web usage."""
  data = open("Koribalski.BGC.machine.table.txt", "rb").read()
  data = ascii.read(data)
  columns = data.colnames
  columns.append('ra')
  columns.append('dec')
  
  output = []
  
  for row in data:
    datum = {}
    
    RAh = row[1]
    RAm = row[2]
    RAs = row[3]
    DESign = row[4]
    DEd = row[5]
    DEm = row[6]
    DEs = row[7]
    ra = Angle("%dh%dm%ds" % (RAh, RAm, RAs))
    dec = Angle("%s%dd%dm%ds" % (DESign, DEd, DEm, DEs))
    
    datum['ra'] = str(Angle("%dh%dm%ds" % (RAh, RAm, RAs)).degrees)
    datum['dec'] = str(Angle("%s%dd%dm%ds" % (DESign, DEd, DEm, DEs)).degrees)
    
    for index, value in enumerate(row):
      column = columns[index]
      datum[column] = str(value)
      
    output.append(datum)
  print json.dumps(output)


if __name__ == '__main__':
  ascii2json()