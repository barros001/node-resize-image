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

  im.identify url, (err, features) ->
    if err
      console.error "when processing #{ url }..."
      console.error(err.stack or err)
    # Imagmagick needs to know what type of file to format the file as.
    # If bmp, format as jpg (some browsers don't like bmp's).
    file_extension = if !features.format or features.format == "BMP"
      ".jpg"
    else
      ".#{features.format}"

    console.log file_extension
    temp.open suffix: file_extension, (err, temp_file) ->
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
