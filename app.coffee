connect = require 'connect'
express = require 'express'
jade = require 'jade'

app = express()

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"
  app.set 'view options', layout: false
  app.use require('connect-assets')()

app.get '/', (request, response) -> response.render 'timecapsule'

server = app.listen(process.env.PORT || 8080)
console.log 'Express server started on port %s', server.address().port
