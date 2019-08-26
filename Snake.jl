#SNAKE
import HTTP, JSON2, Sockets, Logging, JSON
include("gamestate.jl")
include("grids.jl")
include("trees.jl")
include("functionstrategies.jl")


#Setup Server Logging
serverlogfile = open("server.log", "w+")
serverlogger = Logging.SimpleLogger(serverlogfile, Logging.Debug)
Logging.global_logger(serverlogger)



#respondToPing
#When POST is sent to /ping endpoint returns HTTP 200
function respond_to_ping(req::HTTP.Request)
	Logging.@info("[Ping]")
	return HTTP.Response(200)
end


#respondToStart
#When POST is sent to /move responds with Snake move
function respond_to_start(req::HTTP.Request)
	Logging.@info("[Start]")
	#Retrieve Initial Board State and construct the GameState
	return HTTP.Response(200)
end


#respondToMove
#When POST is sent to /move responds with Snake move
function respond_to_move(req::HTTP.Request)
	Logging.@info("[Move]")
	#Create initial gamestate and board
	currentGameState = JSON2.read(IOBuffer(HTTP.payload(req)), GameState)
	reformat_gamestate!(currentGameState)
	generate_gamestate_board!(currentGameState)

	#For right now just going to return the highest weighted node
	#adjacent to my head, for fun.
	easy_best_move = largest_adjacent_weight_dir(currentGameState.you.body[1], currentGameState)

	choice = Dict("move" => easy_best_move)

	#So really what I want to do is generate the decision trees
	#And then just choose the highest weighted node
	#Then return the JSON for the move
	return HTTP.Response(200, body=JSON.json(choice))
end

#respondToShutdown
#When POST is sent to /shutdown stop the server.
function respond_to_shutdown(req::HTTP.Request)
	Logging.@info("[Shut Down]")
	close(serverlogfile)
	close(server)
	quit(0)
end




#Define our endpoints and their corresponding functions
const SNAKE_ROUTER = HTTP.Router()
HTTP.@register(SNAKE_ROUTER, "POST", "/start", respond_to_start)
HTTP.@register(SNAKE_ROUTER, "POST", "/move", respond_to_move)
HTTP.@register(SNAKE_ROUTER, "POST", "/ping", respond_to_ping)
HTTP.@register(SNAKE_ROUTER, "POST", "/shutdown", respond_to_shutdown)



#Start the HTTP Server
function start_server()
	#Start our server
	global server = HTTP.serve(SNAKE_ROUTER, Sockets.localhost, 8081)
	#global server = HTTP.serve(SNAKE_ROUTER, Sockets.getipaddr(), 25565)
end

start_server()