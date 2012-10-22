fs = require("fs")
im = require("imagemagick")
express = require('express')
app = express()

app.get '/:version/:crop/:size/*', (req, res) -> res.send(resize(req))

app.listen(3000)

# TODO
# Figure out how to block the response, we need to download the image and resize, then return that.
# Figure out the correct URL scheme, mirror cloudinary's?
# Figure out how to send the file back. Mime types? Cache headers?
# Figure out how to log/notify on errors.
# Figure out all the different cropping/resizing methods
# Figure out if we need to write the thumbnail to a temp file, and how that works in node.
resize = (req) ->
  url_options = req.params.options
  url         = req.params[0]

  console.log "fetching #{ url } ..."

  options = [url, "-resize", url_options, "cropped.jpg"]

  return im.convert(options)
  #im.convert options, (err, stdout, stderr) ->
    #return console.error(err.stack or err)  if err
    #return stdout if stdout


