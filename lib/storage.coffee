fs = require 'fs'
Sesh = require './sesh'

class SeshsStorage
  constructor: ({@fileName, @domain}) ->
    @all = []
    @bySubdomain = {}

  toJSON: -> @all

  add: (sesh) ->
    @all.push(sesh)
    @bySubdomain[sesh.subdomain] = sesh
    @save()

  remove: (sesh) ->
    delete @bySubdomain[sesh.subdomain]
    @all.splice(@all.indexOf(sesh), 1)
    @save()

  get: (subdomain) ->
    @bySubdomain[subdomain]

  save: ->
    json = JSON.stringify(@all)
    fs.writeFile @fileName, json, (err) ->
      throw err if err

  load: ->
    fs.readFile @fileName, encoding: 'ascii', (err, json) =>
      throw err if err
      try
        @all = JSON.parse(json).map (opt) =>
          opt.domain = @domain
          new Sesh opt
      catch err
        @all = []
      for sesh in @all
        @bySubdomain[sesh.subdomain] = sesh

module.exports = SeshsStorage
