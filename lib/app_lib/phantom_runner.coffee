spawn = require('child_process').spawn
path = require('path')
fs = require('fs')
Uuid = require('node-uuid')

module.exports = class PhantomRunner

  constructor: (@conversionOptions) ->
    @phantomProcess = spawn.apply(this, ['phantomjs', @phantomArguments()])
    @phantomProcess.stdout.on 'data', (data) ->
      console.log 'PhantomJS says: ' + data
    @phantomProcess.stderr.on 'data', (data) ->
      console.log 'PhantomJS cries: ' + data

  on: (event, callback) ->
    switch event
      when 'done'
        @phantomProcess.on 'close', (code) =>
          if code is 0
            pdfBinary = fs.readFileSync(@temporaryFilePath())
            fs.unlink @temporaryFilePath()
            callback(pdfBinary)
      else
        throw new Error("PhantomRunner does not support event: #{event}")

  phantomArguments: ->
    [
      '--web-security=no'
      '--ssl-protocol=any'
      @absolutePathToPhantomScript()
      @conversionOptions.source_url
      @temporaryFilePath()
      @conversionOptions.paperFormat
      @conversionOptions.orientation
      @conversionOptions.margin
      @conversionOptions.zoom
    ]

  temporaryFilePath: ->
    @_temporaryFilePath ?= @generateTmpPath()

  generateTmpPath: ->
    path.join('/tmp', Uuid.v4() + '.pdf')

  absolutePathToPhantomScript: ->
    path.join(__dirname, '../rasterize/rasterize.js')