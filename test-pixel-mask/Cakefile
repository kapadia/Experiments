{print} = require 'util'
{spawn} = require 'child_process'

task 'build', 'Build lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'server', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
  stylus = spawn 'stylus', ['-w', '-c', '-o', 'lib', 'src']
  server = spawn 'http-server'
  
  for p in [coffee, server, stylus]
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()