connect = require 'connect'
express = require 'express'
jade = require 'jade'
crypto = require 'crypto'
moment = require 'moment'

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
  payload =
    createTime: moment().unix()
    openTime: moment(capsule.time).unix()
    message: capsule.message

  secret = process.env.CRYPTO_SECRET || 'testmode'
  cipher = crypto.createCipher('aes-256-cbc', secret)
  crypted = cipher.update(JSON.stringify(payload),'utf8', 'base64')
  crypted += cipher.final('base64')

  if crypted.length < 1800
    url = "http://timebottle.herokuapp.com/view?capsule=" + encodeURIComponent(crypted)

  response.render 'new', locals:
    openTimeFormatted: moment(payload.openTime).format('MMMM Do YYYY, h:mm a')
    capsule: crypted
    capsule_url: url

server = app.listen(process.env.PORT || 8080)
console.log 'Express server started on port %s', server.address().port
