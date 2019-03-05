module SnakeServer

include("logic.jl")
include("graphfunctions.jl")
import HTTP, JSON2, Sockets, Logging

#Setup Server Logging
serverlogfile = open("server.log", "w+")
serverlogger = Logging.SimpleLogger(serverlogfile, Logging.Debug)
Logging.global_logger(serverlogger)


currentGameState = GameState()

#respondToPing
#When POST is sent to /ping endpoint returns HTTP 200
function respondToPing(req::HTTP.Request)
	Logging.@info("[Ping]")
	return HTTP.Response(200)
end


#respondToStart
#When POST is sent to /move responds with Snake move
function respondToStart(req::HTTP.Request)
	Logging.@info("[Start]")
	#Retrieve Initial Board State and construct the GameState
	currentGameState = JSON2.read(IOBuffer(HTTP.payload(req)), GameState)
	defaultBoard = MetaGraph(LightGraphs.SimpleGraphs.Grid([currentGameState.board.width, currentGameState.board.height]), 0.0)
	currentGameState = GameState(currentGameState, defaultBoard)
	Logging.@debug "After Initial GameState Generation" currentGameState
	Logging.@debug "Nodes in graph" LightGraphs.vertices(currentGameState.graph)
	renameGraphNodes(currentGameState.graph, currentGameState.board.width)



	
	return HTTP.Response(200)
end


#respondToMove
#When POST is sent to /move responds with Snake move
function respondToMove(req::HTTP.Request)
	Logging.@info("[Move]")
	currentGameState = JSON2.read(IOBuffer(HTTP.payload(req)), GameState)
	println(currentGameState)
	return HTTP.Response(200)
end

#respondToShutdown
#When POST is sent to /shutdown stop the server.
function respondToShutdown(req::HTTP.Request)
	Logging.@info("[Shut Down]")
	close(serverlogfile)
	close(server)
	quit(0)
end






#Define our endpoints and their corresponding functions
const SNAKE_ROUTER = HTTP.Router()
HTTP.@register(SNAKE_ROUTER, "POST", "/start", respondToStart)
HTTP.@register(SNAKE_ROUTER, "POST", "/move", respondToMove)
HTTP.@register(SNAKE_ROUTER, "POST", "/ping", respondToPing)
HTTP.@register(SNAKE_ROUTER, "POST", "/shutdown", respondToShutdown)



#Start the HTTP Server
function startServer()
	#Start our server
	global server = HTTP.serve(SNAKE_ROUTER, Sockets.localhost, 8081)
	#global server = HTTP.serve(SNAKE_ROUTER, Sockets.getipaddr(), 25565)
end


end
