fs = require("fs")
im = require("imagemagick")
express = require('express')
temp = require('temp')

app = express()

app.get '/:version/:crop/:size/:url(*)', (req, res) ->
  # TODO
  # Figure out the correct URL scheme
  # Figure out how to send the file back. Mime types? Cache headers?
  # Figure out how to log/notify on errors.
  # Figure out all the different cropping/resizing methods
  console.log req.params
  size = req.params.size
  url  = req.params.url

  console.log "fetching #{ url } ..."

  temp.open 'thumbnail-', (err, info) ->
    options = [url, "-resize", size, info.path]
    console.log "Writing to #{info.path}"
    im.convert options, (err, stdout, stderr) ->
      console.error(err.stack or err) if err
      console.log(stdout) if stdout
      res.sendfile info.path

  # I need to block until the above is done? Or a better way to do this?

app.listen(3000)
