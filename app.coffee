connect = require 'connect'
express = require 'express'
jade = require 'jade'

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
		response.render 'new'

server = app.listen(process.env.PORT || 8080)
console.log 'Express server started on port %s', server.address().port
