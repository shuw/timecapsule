express = require 'express'
app = express()

app.get '/', (req, res) ->
	res.send 'hello world\n'

server = app.listen(8080)
console.log 'Express server started on port %s', server.address().port
