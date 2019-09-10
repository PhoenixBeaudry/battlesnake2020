include("gamestate.jl")
include("functionstrategies.jl")

##### TODOS #####

#@IDEA when the node weight is finally implemented, maybe give 
#		high weights to dead enemy snakes, eg. aggressive strat.

#@TODO Add Typing to most methods.

##### END #####

##### STRUCTS #####
mutable struct Point
	type
	weight::Float64
	Point() = new(".", 0.0)
	Point(type, weight) = new(type, weight)
end

##### END #####


##### GAMEBOARD AND GAMESTATE GENERATION #####

#Converts all indexes in GameState to 1-indexing.
function reformat_gamestate!(gamestate)

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

#Takes the gamestate and turns it into a board
function generate_gamestate_board!(gamestate)
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

#Given an index, returns all nodes that are 'depth' away
#Return: tuple array
function nodes_of_depth_distance(seed::NamedTuple, depth, dim)
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
function influence!(board, seed, func, depth)
	for currentdepth = 0:depth
		currentnodes = nodes_of_depth_distance(seed, currentdepth, size(board)[1])
		for node in currentnodes
			board[node.x, node.y] = Point(board[node.x, node.y].type, board[node.x, node.y].weight + func(currentdepth))
		end
	end
end


##### END #####


##### HIGHER LEVEL LOGIC #####


#Simulates the game one step, assuming all enemy snakes
# take the best adjacent weighted node and you take 'mymove' (direction string)
# RETURN: ::GameState
#@FIX If food is collected dont remove tail.
function simulate_one_move(gamestate, mymove)
	newgamestate = deepcopy(gamestate)
	#Move each snake
	for snake in newgamestate.board.snakes
		if(snake.body[1] != newgamestate.you.body[1])
			#Find the best move
			move = largest_adjacent_node(snake.body[1], gamestate)
			#Simulate move by removing tail and head and adding new head
			pop!(snake.body)
			pushfirst!(snake.body, move)
			#If food overlap, remove food.
			if(in(move, newgamestate.board.food))
				splice!(newgamestate.board.food, move)
			end
		else
			move = direction_to_node(snake.body[1], mymove)
			#Simulate move by removing tail and head and adding new head
			pop!(snake.body)
			pushfirst!(snake.body, move)
		end
	end
	#Move yourself object
	move = direction_to_node(newgamestate.you.body[1], mymove)
	#Simulate move by removing tail and head and adding new head
	pop!(newgamestate.you.body)
	pushfirst!(newgamestate.you.body, move)
	#If food overlap, remove food.
	if(in(move, newgamestate.board.food))
		splice!(newgamestate.board.food, move)
	end
	generate_gamestate_board!(newgamestate)

	return(newgamestate)

end

##### END #####


##### MOVE UTILITIES #####

function direction_to_node(location, dir)
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


#returns best move node based on high weighted nodes
function largest_adjacent_node(location, gamestate)
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


#returns direction of best move based on high weighted nodes
#@CLEAN Rename this stupid function lol
function largest_adjacent_weight_dir(location, gamestate)
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
function print_board(gamestate)
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