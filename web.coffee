express = require('express')
path    = require('path')
exec    = require('child_process').exec

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

app = express.createServer()

# :version: can be used to re-generate thumbnails
# :options: c_fill, w_200, h_200
# :url:     the source url
app.get '/:version/:options/:url(*)', (req, res) ->
  url     = req.params.url
  options = req.params.options

  width   = options.match(/w_(\d+)/)?[1] || ''
  height  = options.match(/h_(\d+)/)?[1] || ''
  crop    = options.match(/c_(\w+)/)?[1] || ''
  gravity = options.match(/g_(\w+)/)?[1] || 'center'

  # sanitize gravity parameter
  if gravity not in ['none', 'center', 'east', 'forget', 'northeast', 'north', 'northwest', 'southeast', 'south',
                     'southwest', 'west']
    gravity = 'center'

  size = "#{width}x#{height}"

  # magick_options is an array of parameters that we pass to imagemagick's `convert` program.
  command = ["/bin/bash ./resize.sh", url]

  if crop == 'fill'
    # We are resizing and cropping to fit
    size += "^"
    command.push "-thumbnail"
    command.push size
    command.push "-gravity"
    command.push gravity
    command.push "-extent"
    command.push size
    command.push "-quality"
    command.push "70"
  else if width or height
    # We are resizing
    command.push "-thumbnail"
    command.push size
    command.push "-quality"
    command.push "70"
  else
    # Just fetching the original image and returning it.

  command_string = command.join(' ')
  exec command_string, (error, stdout, stderr) ->
    if error
      str = "problem for "
      str += req.originalUrl
      str += " from "
      str += req.get('referer')
      console.log str
      console.log "error: #{ error}"
      console.log "stderr: #{ stderr}" if stderr
      res.status(404).send('Not found')
    else
      filename = stdout.strip()
      # Send the thumbnail to the client with a expires a year from now
      # Need workaround to work with node 0.10
      # http://stackoverflow.com/questions/15557480/node-js-typeerror-with-path-join-when-serving-webpage-with-express
      relative = path.basename(filename)
      root     = path.dirname(filename)
      age = 60*60*24*365*1000
      res.sendfile relative, root: root, maxAge: age, ->
        exec "rm #{ filename }"

app.listen(process.env.PORT || 3000)
