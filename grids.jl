include("gamestate.jl")
include("functionstrategies.jl")
#Grid Creation
mutable struct Point
	type
	weight::Float64
	Point() = new(".", 0.0)
	Point(type, weight) = new(type, weight)
end

#Creates an empty board matrix (filled with Points)
function create_board_matrix(width, height)
	board = Matrix{Point}(undef, width, height)
	fill!(board, Point())
	return board
end


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
#@CLEAN board dimensions could be taken from board, not passed as parameters
function influence!(board, seed, func, depth)
	for currentdepth = 0:depth
		currentnodes = nodes_of_depth_distance(seed, currentdepth, size(board)[1])
		for node in currentnodes
			board[node.x, node.y] = Point(board[node.x, node.y].type, board[node.x, node.y].weight + func(currentdepth))
		end
	end
end


#Takes the gamestate and turns it into a board
function gamestate_to_board!(gamestate, board)
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
end


#returns direction of best move based on high weighted nodes
function largest_adjacent_weight_dir(location, board)
	adjacentnodes = nodes_of_depth_distance(location, 1, size(board)[1])
	highestnode = (x=-1, y=-1)
	highestweight = -100000
	for node in adjacentnodes
		 if(board[node.x, node.y].weight > highestweight)
		 	highestnode = node
		 	highestweight = board[node.x, node.y].weight
		 end
	end

	if location.x == highestnode.x && location.y < highestnode.y
        return "up"
    end
    if location.x == highestnode.x && location.y > highestnode.y
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




##### PRINTING #####

#Prints a board, by type and weight
function print_board(board::Matrix{Point})
	println("Type board:")
	boardstring = ""
	for row in eachrow(board)
		rowstring = ""
		for point in row
			rowstring = rowstring*(point.type*" ")
		end
		boardstring = rowstring*"\n"*boardstring
	end
	println(boardstring)


	println("Weight board:")
	boardstring = ""
	for row in eachrow(board)
		rowstring = ""
		for point in row
			rowstring = rowstring*(string(round(point.weight, sigdigits=2))*"     ")
		end
		boardstring = rowstring*"\n\n\n"*boardstring
	end
	println(boardstring)
end
