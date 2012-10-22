fs = require("fs")
im = require("imagemagick")
express = require('express')
app = express()

app.get '/:version/:options/*', (req, res) -> res.send(resize(req))

app.listen(3000)

resize = (req) ->
  url_options = req.params.options
  url         = req.params[0]

  console.log url
  console.log "fetching #{ url } with #{ url_options }..."
  console.log url_options

  width  = url_options.match(/w_(\d*)/)?[1]
  height = url_options.match(/h_(\d*)/)?[1]
  crop   = url_options.match(/c_(\w*)/)?[1]

  options = {srcPath: url, dstPath: 'cropped.jpg'}

  options.width  = width  if width
  options.height = height if height


  im.crop options, (err, stdout, stderr) ->
    return console.error(err.stack or err)  if err
    return stdout if stdout


#resize('https://s3.amazonaws.com/tanga-images/gwpj7hsbktne.png')
#resize('https://s3.amazonaws.com/tanga-images/gwpj7hsbktne.png')
