include("gamestate.jl")
include("functionstrategies.jl")

##### TODOS #####

#@IDEA when the node weight is finally implemented, maybe give 
#		high weights to dead enemy snakes, eg. aggressive strat.

#@TODO Add Typing to most methods.

#@FIX While head collision vs larger enemy snakes is considered a death
# the move should still be taken if it is less 'guaranteed'

#@REFACTOR Convert as many Arrays to Sets as possible?

##### END #####

##### GAMEBOARD AND GAMESTATE GENERATION #####

# reformat_gamestate!(::GameState)
# RETURN: None
# Converts all indexes in GameState to 1-indexing.
function reformat_gamestate!(gamestate::GameState)

	newfood = []
	for food in gamestate.board.food
		push!(newfood, (x=food.x+1, y=food.y+1))
	end

	newsnakelist = []
	for snake in gamestate.board.snakes
		newbody = []
		for part in snake.body
			push!(newbody, (x=part.x+1, y=part.y+1))
		end
		newsnake = (id=snake.id, name=snake.name, health=snake.health, body=newbody)
		push!(newsnakelist, newsnake)
	end

	gamestate.board = (height=gamestate.board.height, width=gamestate.board.width, food=newfood, snakes=newsnakelist)


	newbody = []
	for part in gamestate.you.body
		push!(newbody, (x=part.x+1, y=part.y+1))
	end
	newyou = (id=gamestate.you.id, name=gamestate.you.name, health=gamestate.you.health, body=newbody)

	gamestate.you = newyou

	return
end

# generate_gamestate_board!(::GameState)
# RETURN: None
# Generates the boardmatrix from the gamestate and stores in gamestate struct
function generate_gamestate_board!(gamestate::GameState)
	board = Matrix{Point}(undef, gamestate.board.width, gamestate.board.height)
	fill!(board, Point())
	for food in gamestate.board.food
		board[food.x, food.y] = Point("F", 0.0)
		influence!(board, food, food_decay, 5)
	end
	for snake in gamestate.board.snakes
		for part in snake.body
			board[part.x, part.y] = Point("E", 0.0)
			influence!(board, part, enemy_decay, 5)
		end
	end
	gamestate.matrix = board
end

# nodes_of_depth_distance(::NamedTuple, ::Int, ::Tuple)
# RETURN: TupleArray
# Given an index, returns all nodes that are 'depth' away
#@FIX dim doesnt support non square boards.
function nodes_of_depth_distance(seed::NamedTuple{(:x, :y),Tuple{Int, Int}}, depth::Int, dim::Int)
	nodes = Set()

	#Only return seed if depth is 0
	if(depth == 0)
		push!(nodes, seed)
		return nodes
	end

	#Find triangle vertices
	triangleup = (x=seed.x, y=seed.y+depth)
	triangledown = (x=seed.x, y=seed.y-depth)
	triangleleft = (x=seed.x-depth, y=seed.y)
	triangleright = (x=seed.x+depth, y=seed.y)

	#Find connecting points
	for i = 0:depth
		push!(nodes, (x=triangleup.x+i, y=triangleup.y-i))
		push!(nodes, (x=triangleright.x-i, y=triangleright.y-i))
		push!(nodes, (x=triangledown.x-i, y=triangledown.y+i))
		push!(nodes, (x=triangleleft.x+i, y=triangleleft.y+i))
	end

	#@CLEAN
	#COULD BE ADDED INTO push!es
	for node in nodes
		if(node.x<1 || node.y<1 || node.x>dim || node.y>dim)
			pop!(nodes, node)
		end
	end

	return nodes
end


#Spreads weights from points of interest across the board
# influence!(board, seed, func, depth)
# RETURN: None
function influence!(board::Array{Point,2}, seed::NamedTuple{(:x, :y),Tuple{Int, Int}}, func, depth::Int)
	for currentdepth = 0:depth
		currentnodes = nodes_of_depth_distance(seed, currentdepth, size(board)[1])
		for node in currentnodes
			board[node.x, node.y] = Point(board[node.x, node.y].type, board[node.x, node.y].weight + func(currentdepth))
		end
	end
end


##### END #####


##### HIGHER LEVEL LOGIC #####

# simulate_one_move(::GameState, ::String)
# RETURN: ::GameState
# Simulates the game one step, assuming all enemy snakes
# take the best adjacent weighted node and you take 'mymove' (direction string)
function simulate_one_move(gamestate::GameState, mymove::String)

	#Check wall collisions, if collision return.
	target = direction_to_node(gamestate.you.body[1], mymove)
	if(target.x < 1 || target.y < 1 || target.x > gamestate.board.width || target.y > gamestate.board.height)
		return -1
	end

	#Before major simulating check if its a 'enemy snake might eat me state' and count as death?? Or perhaps very low weight.
	for snake in gamestate.board.snakes
		if(snake.body[1] != gamestate.you.body[1])
			if(adjacent_nodes(target, snake.body[1]) && length(snake.body) >= length(gamestate.you.body))
				return -1
			end	
		end
	end

	newgamestate = deepcopy(gamestate)
	#Move each snake
	for snake in newgamestate.board.snakes
		if(snake.body[1] != newgamestate.you.body[1])
			#Find the best move
			move = largest_adjacent_node(snake.body[1], gamestate)
			#Simulate move by removing tail and head and adding new head
			if(length(snake.body)==1 || in(move, newgamestate.board.food))
				pushfirst!(snake.body, move)
			else
				pop!(snake.body)
				pushfirst!(snake.body, move)
			end
			#If food overlap, remove food.
			if(in(move, newgamestate.board.food))
				splice!(newgamestate.board.food, findfirst(isequal(move), newgamestate.board.food))
			end
		else
			move = direction_to_node(snake.body[1], mymove)
			#Simulate move by removing tail and head and adding new head
			if(length(snake.body)==1 || in(move, newgamestate.board.food))
				pushfirst!(snake.body, move)
			else
				pop!(snake.body)
				pushfirst!(snake.body, move)
			end
		end
	end
	#Move yourself
	move = direction_to_node(newgamestate.you.body[1], mymove)
		#Make sure move isnt into tail if size two.
	if(length(newgamestate.you.body)==2)
		if(move == newgamestate.you.body[2])
			return -1
		end
	end
		#Simulate move by removing tail and head and adding new head
	if(length(newgamestate.you.body)==1 || in(move, newgamestate.board.food))
		pushfirst!(newgamestate.you.body, move)
	else
		pop!(newgamestate.you.body)
		pushfirst!(newgamestate.you.body, move)
	end
		#If food overlap, remove food.
	if(in(move, newgamestate.board.food))
		splice!(newgamestate.board.food, findfirst(isequal(move), newgamestate.board.food))
		newgamestate.you = (id=newgamestate.you.id, name=newgamestate.you.name, health=100, body=newgamestate.you.body)
	end

	#Check if starve condition.
	if(newgamestate.you.health-1 == 0)
		return -1
	end

	#Tick health down by one.
	newgamestate.you = (id=newgamestate.you.id, name=newgamestate.you.name, health=newgamestate.you.health-1, body=newgamestate.you.body)

	#Before generating the board, check if move results in death, if it does, return.
		#Check your collisions
	if(newgamestate.you.body[1] in newgamestate.you.body[2:end])
		return -1
	end

		#Check enemy collisions
	for snake in newgamestate.board.snakes
		if(snake.body[1] != newgamestate.you.body[1])
			if(newgamestate.you.body[1] in snake.body)
				return -1
			end
		end
	end

	#Generate board and return.
	generate_gamestate_board!(newgamestate)
	return(newgamestate)

end

##### END #####


##### MOVE UTILITIES #####

# adjacent_nodes(::NamedTuple, ::NamedTuple)
# RETURN: ::Boolean
function adjacent_nodes(node1::NamedTuple{(:x, :y),Tuple{Int, Int}}, node2::NamedTuple{(:x, :y),Tuple{Int, Int}})
	if(node1.x != node2.x && node1.y != node2.y)
		return false
	elseif(node1.x == node2.x && (node1.y == node2.y+1 || node1.y == node2.y-1))
		return true
	elseif(node1.y == node2.y && (node1.x == node2.x+1 || node1.x == node2.x-1))
		return true
	end
	return false

end

# direction_to_node(::NamedTuple, :String)
# RETURN: ::NamedTuple
# Converts a coordinate and a direction to another coordinate
function direction_to_node(location::NamedTuple{(:x, :y),Tuple{Int, Int}}, dir::String)
	if(dir == "left")
		return (x=location.x-1,y=location.y)
	elseif(dir == "right")
		return (x=location.x+1,y=location.y)
	elseif(dir == "up")
		return (x=location.x,y=location.y-1)
	elseif(dir == "down")
		return (x=location.x,y=location.y+1)
	end

	return (x=-1,y=-1)
end

# largest_adjacent_node(::Namedtuple, ::GameState)
# RETURN: ::NamedTuple
# Returns best move node based on high weighted nodes
function largest_adjacent_node(location::NamedTuple{(:x, :y),Tuple{Int, Int}}, gamestate::GameState)
	adjacentnodes = nodes_of_depth_distance(location, 1, size(gamestate.matrix)[1])
	highestnode = (x=-1, y=-1)
	highestweight = -100000
	for node in adjacentnodes
		 if(gamestate.matrix[node.x, node.y].weight > highestweight)
		 	highestnode = node
		 	highestweight = gamestate.matrix[node.x, node.y].weight
		 end
	end

    return highestnode
end

# largest_adjacent_weight_dir(::NamedTuple, ::GameState)
# RETURN ::String
# Returns direction of best move based on high weighted nodes
#@CLEAN Rename this stupid function lol
function largest_adjacent_weight_dir(location::NamedTuple{(:x, :y),Tuple{Int, Int}}, gamestate::GameState)
	adjacentnodes = nodes_of_depth_distance(location, 1, size(gamestate.matrix)[1])
	highestnode = (x=-1, y=-1)
	highestweight = -100000
	for node in adjacentnodes
		 if(gamestate.matrix[node.x, node.y].weight > highestweight)
		 	highestnode = node
		 	highestweight = gamestate.matrix[node.x, node.y].weight
		 end
	end

	if location.x == highestnode.x && location.y > highestnode.y
        return "up"
    end
    if location.x == highestnode.x && location.y < highestnode.y
        return "down"
    end
    if location.x < highestnode.x && location.y == highestnode.y
        return "right"
    end
    if location.x > highestnode.x && location.y == highestnode.y
        return "left"
    end

    return "uhoh"
end

##### END #####


##### PRINTING #####

#Prints a board, by type and weight
function print_board(gamestate::GameState)
	println("Type board:")
	for column in eachcol(gamestate.matrix)
		for point in column
			print(point.type*" ")
		end
		println()
	end

	println("Weight board:")
	for column in eachcol(gamestate.matrix)
		for point in column
			print(string(round(point.weight, sigdigits=2))*"     ")
		end
		println()
	end
end


##### END #####