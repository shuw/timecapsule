connect = require 'connect'
express = require 'express'
jade = require 'jade'
crypto = require 'crypto'
moment = require 'moment'

CRYPTO_SECRET = process.env.CRYPTO_SECRET || 'testmode'
TIME_FORMAT = 'MMMM Do YYYY, h:mma'

app = express()
app.use(require('connect').bodyParser())

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"
  app.set 'view options', layout: false
  app.use require('connect-assets')()

app.get '/', (request, response) -> response.render 'index'

app.get '/view', (request, response) ->
  if request.query.capsule
    gotCapsule = true

    decipher = crypto.createDecipher('aes-256-cbc', CRYPTO_SECRET)
    dec = decipher.update(request.query.capsule, 'base64', 'utf8')
    dec += decipher.final('utf8')
    payload = JSON.parse(dec)

    createTime = moment.unix(payload.createTime)
    openTime = moment.unix(payload.openTime)
    sealedDurationDays = Math.max(openTime.diff(createTime, 'days'), 0)

    if moment() >= openTime
      canOpen = true
      message = payload.message

  response.render 'view', locals:
    gotCapsule: gotCapsule
    canOpen: canOpen
    message: message
    sealedDurationDays: sealedDurationDays
    openTimeFromNow: openTime.fromNow()
    openTimeFormatted: openTime.format(TIME_FORMAT)
    createTimeFromNow: createTime.fromNow()
    createTimeFormatted: createTime.format(TIME_FORMAT)


app.post '/new', (request, response) ->
  capsule = request.body.capsule
  payload =
    createTime: moment().unix()
    openTime: moment(capsule.time).unix()
    message: capsule.message

  cipher = crypto.createCipher('aes-256-cbc', CRYPTO_SECRET)
  crypted = cipher.update(JSON.stringify(payload),'utf8', 'base64')
  crypted += cipher.final('base64')

  if crypted.length < 1800
    url = "/view?capsule=" + encodeURIComponent(crypted)

  response.render 'new', locals:
    openTimeFormatted: moment.unix(payload.openTime).format(TIME_FORMAT)
    capsule: crypted
    capsule_url: url

server = app.listen(process.env.PORT || 8080)
console.log 'Express server started on port %s', server.address().port
