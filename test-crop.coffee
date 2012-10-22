fs = require("fs")
im = require("imagemagick")
express = require('express')
temp = require('temp')

app = express()
app.get '/:version/:crop/:size/*', (req, res) -> res.send(resize(req))
app.listen(3000)

# TODO
# Figure out how to block the response, we need to download the image and resize, then return that.
# Figure out the correct URL scheme
# Figure out how to send the file back. Mime types? Cache headers?
# Figure out how to log/notify on errors.
# Figure out all the different cropping/resizing methods
resize = (req) ->
  console.log req.params
  size = req.params.size
  url  = req.params[0]

  console.log "fetching #{ url } ..."

  temp.open 'thumbnail-', (err, info) ->
    options = [url, "-resize", size, info.path]
    console.log "Writing to #{info.path}"
    im.convert options, (err, stdout, stderr) ->
      return console.error(err.stack or err)  if err
      return stdout if stdout


