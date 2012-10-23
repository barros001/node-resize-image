fs      = require("fs")
im      = require("imagemagick")
express = require('express')
temp    = require('temp')

app = express.createServer()

# :version: can be used to re-generate thumbnails
# :options: c_fill, w_200, h_200
# :url:     the source url
app.get '/:version/:options/:url(*)', (req, res) ->
  url     = req.params.url
  options = req.params.options

  console.log "fetching #{ url } and applying these options: #{ options }..."

  width  = options.match(/w_(\d+)/)?[1] || ''
  height = options.match(/h_(\d+)/)?[1] || ''
  crop   = options.match(/c_(\w+)/)?[1] || '' # c_fill is the only special option now.

  size = "#{width}x#{height}"

  # magick_options is an array of parameters that we pass to imagemagick's `convert` program.
  magick_options = [url]

  if crop == 'fill'
    # We are resizing and cropping to fit
    size += "^"
    magick_options.push "-thumbnail"
    magick_options.push size
    magick_options.push "-gravity"
    magick_options.push "center"
    magick_options.push "-extent"
    magick_options.push size
  else if width or height
    # We are resizing
    magick_options.push "-thumbnail"
    magick_options.push size
  else
    # Just fetching the original image and returning it.

  # Open a temp file
  temp.open suffix: url[-5..-1], (err, info) ->
    # Add the temp file's path to the options to give to imagemagick
    magick_options.push info.path

    # Generate the thumbnail
    im.convert magick_options, (err, stdout, stderr) ->
      console.error(err.stack or err) if err
      console.log(stdout) if stdout
      # Send the thumbnail to the client with a expires a year from now
      res.sendfile info.path, maxAge: 60*60*24*365*1000

app.listen(process.env.PORT || 3000)
