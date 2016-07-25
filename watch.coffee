# use this to automatically copy files in to your pier:
#
# > npm install
# > coffee watch.coffee
#
# you'll need a config.json that looks like config_example.json

fs     = require 'fs'
watch  = require 'watch'

c = JSON.parse fs.readFileSync 'config.json'

i = 0

tail = (f) ->
  _f = f.split("/")
  _f = _f[_f.length-1]

copy = (f,dir) ->
  for exp in c.ignore
    if f.match(new RegExp(exp, 'i')) isnt null
      console.log "#{Number(new Date())} - ignoring change in: #{tail(f)}"
      return

  t = f.replace dir.source,dir.target

  console.log "#{Number(new Date())} - copying #{tail(f)} to #{tail(t)}"

  rd = fs.createReadStream f
  wr = fs.createWriteStream t
  err = -> console.log arguments
  rd.on 'error', err
  wr.on 'error', err
  rd.pipe wr

walk = (dir) ->
  console.log "watching files in #{dir.source}"
  watch.createMonitor dir.source, (monitor) ->
    monitor.on 'created', (f,curr,prev) -> copy f,dir
    monitor.on 'changed', (f,curr,prev) -> copy f,dir

    i++
    if i < c.watch.length
      walk c.watch[i]

walk c.watch[i]
