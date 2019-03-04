module SnakeServer

import HTTP
import JSON2
import Sockets

mutable struct GameState
	turn::Int
	snakes::Array
	food::Array
end

#respondToPing
#When POST is sent to /ping endpoint returns HTTP 200
function respondToPing(req::HTTP.Request)
	return HTTP.Response(200)
end

#respondToMove
#When POST is sent to /move responds with Snake move
function respondToMove(req::HTTP.Request)
	#currentGameState = JSON2.read(IOBuffer(HTTP.payload(req)), GameState)
	return HTTP.Response(200)
end


#Define our endpoints and their corresponding functions
const SNAKE_ROUTER = HTTP.Router()
HTTP.@register(SNAKE_ROUTER, "POST", "/move", respondToMove)
HTTP.@register(SNAKE_ROUTER, "POST", "/ping", respondToPing)


#Start the HTTP Server
function startServer()
	#Start our server
	HTTP.serve(SNAKE_ROUTER, Sockets.localhost, 8081)
end


end