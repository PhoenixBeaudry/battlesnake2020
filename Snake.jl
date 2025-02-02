#SNAKE

##### TODOS #####

#@IDEA Currently the enemy ai doesnt account for aggressive snakes
# they only follow the highest weighted path in the gamestate matrix.

#@TODO Make snake afraid of possible head on head collisions with larger snakes.
# and favour collisions if bigger snake.

#@IDEA Use current system for start of game when multiple snakes as its easy
# to simulate 'dumb' enemies. Once 1v1 switch to more classic minimax.

##### END #####

import HTTP, JSON2, Sockets, Logging, JSON
include("gamestate.jl")
include("grids.jl")
include("trees.jl")
include("functionstrategies.jl")


#Setup Server Logging
serverlogfile = open("server.log", "w+")
serverlogger = Logging.SimpleLogger(serverlogfile, Logging.Debug)
Logging.global_logger(serverlogger)


# respond_to_ping
# When POST is sent to /ping endpoint returns HTTP 200
function respond_to_ping(req::HTTP.Request)
	println("[Ping]")
	Logging.@info("[Ping]")
	return HTTP.Response(200)
end


# respond_to_start
# When POST is sent to /move responds with Snake move
function respond_to_start(req::HTTP.Request)
	println("[Start]")
	Logging.@info("[Start]")
	#Retrieve Initial Board State and construct the GameState
	return HTTP.Response(200)
end


# respond_to_move
# When POST is sent to /move responds with Snake move
function respond_to_move(req::HTTP.Request)
	println("[Move]")
	Logging.@info("[Move]")
	#Log the request
	Logging.@debug(req)
	#Create initial gamestate and board
	currentGameState = JSON2.read(IOBuffer(HTTP.payload(req)), GameState)
	reformat_gamestate!(currentGameState)
	generate_gamestate_board!(currentGameState)

	# Generate the dang decision tree w/ given foresight depth
	tree = generate_decision_tree(currentGameState, 4)
	move = best_move(tree)

	choice = Dict("move" => move)
	Logging.@info("Chosen move: ", move)

	#So really what I want to do is generate the decision trees
	#And then just choose the highest weighted node
	#Then return the JSON for the move
	return HTTP.Response(200, body=JSON.json(choice))
end


# respond_to_shutdown
# When POST is sent to /shutdown stop the server.
function respond_to_shutdown(req::HTTP.Request)
	println("[Shut Down]")
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
	global server = HTTP.serve(SNAKE_ROUTER, Sockets.getipaddr(), 25565)
end

start_server()