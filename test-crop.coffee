fs = require("fs")
im = require("imagemagick")
express = require('express')
temp = require('temp')

app = express()

app.get '/:version/:options/:url(*)', (req, res) ->
  # TODO
  # Figure out the correct URL scheme
  # Figure out how to send the file back. Mime types? Cache headers?
  # Figure out how to log/notify on errors.
  # Figure out all the different cropping/resizing methods
  console.log req.params
  size = req.params.size
  url  = req.params.url
  crop = req.params.crop
  options = req.params.options

  console.log "fetching #{ url } ..."

  width  = options.match(/w_(\d+)/)?[1] || ''
  height = options.match(/h_(\d+)/)?[1] || ''
  crop   = options.match(/c_(\w+)/)?[1] || ''

  size = "#{width}x#{height}"

  magick_options = [url]
  magick_options.push "-resize"
  if crop == 'fill'
    magick_options.push (size + "^")
    magick_options.push "-gravity"
    magick_options.push "center"
    magick_options.push "-extent"
    magick_options.push (size + "^")
  else
    magick_options.push size

  temp.open suffix: url[-5..-1], (err, info) ->
    magick_options.push info.path
    console.log magick_options
    console.log "Writing to #{info.path}"

    im.convert magick_options, (err, stdout, stderr) ->
      console.error(err.stack or err) if err
      console.log(stdout) if stdout
      res.sendfile info.path, maxAge: 60*60*24*365*1000

app.listen(process.env.PORT || 3000)
