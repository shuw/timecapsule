connect = require 'connect'
express = require 'express'
jade = require 'jade'
crypto = require('crypto')

app = express()
app.use(require('connect').bodyParser())

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"
  app.set 'view options', layout: false
  app.use require('connect-assets')()

app.get '/', (request, response) -> response.render 'index'

app.post '/new', (request, response) ->
  capsule = request.body.capsule

  secret = process.env.CRYPTO_SECRET || 'testmode'
  cipher = crypto.createCipher('aes-256-cbc', secret)
  crypted =
    cipher.update(capsule.payload,'utf8','hex') +
    cipher.final('hex')

  console.log "hello world"
  console.log crypted

  response.render 'new',
    locals:
      capsule: crypted

server = app.listen(process.env.PORT || 8080)
console.log 'Express server started on port %s', server.address().port
