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
  crop   = options.match(/c_(\w+)/)?[1] || ''
  format = options.match(/f_(\w+)/)?[1] || ''

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
    magick_options.push "-quality"
    magick_options.push "70"
  else if width or height
    # We are resizing
    magick_options.push "-thumbnail"
    magick_options.push size
    magick_options.push "-quality"
    magick_options.push "70"
  else
    # Just fetching the original image and returning it.

  # What the file extension of the temporary file should be.
  # imagemagick uses this to determine what format the image should be.
  # We either use the format specified in the options, or the last few
  # characters of the URL. Possibly need a better way to do this.
  suffix = "." + (format || url[-5..-1])

  # Open a temp file
  temp.open suffix: suffix, (err, temp_file) ->
    # Add the temp file's path to the options to give to imagemagick
    magick_options.push temp_file.path

    # Generate the thumbnail
    im.convert magick_options, (err, stdout, stderr) ->
      if err or stdout
        console.error "when processing #{ url }..."
        console.error(err.stack or err) if err
      console.log(stdout) if stdout
      # Send the thumbnail to the client with a expires a year from now
      res.sendfile temp_file.path, maxAge: 60*60*24*365*1000

app.listen(process.env.PORT || 3000)
