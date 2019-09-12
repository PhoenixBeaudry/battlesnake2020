using Printf
include("grids.jl")
include("gamestate.jl")

##### TODOS #####

#@IDEA Use Julia Multithreading to generate nodes and weights (@spawn).

#@FIX Major revisions needed: due to summing nodes, deeper branches death leafs add up,
# outweighing immediate deaths. Current work around is just to check for -10000 equality, not great

#@REMIND Only leaf nodes contribute to weight, at least I think thats best.

#@REMIND Dont forget to take into account starvation, must incentivise food in weight.


##### END #####

##### Data Structures #####
mutable struct Node
	gamestate::GameState
	weight::Int64
	direction
	left::Union{Nothing, Node}
	right::Union{Nothing, Node}
	up::Union{Nothing, Node}
	down::Union{Nothing, Node}
	Node() = new()
	Node(gamestate::GameState) = new(gamestate)
end

mutable struct Tree
	root::Node
	Tree(rootgamestate::GameState) = new(Node(rootgamestate))
end

##### END #####

##### Decision Tree #####

# generate_decision_tree(::GameState, ::Int64)
# RETURN: ::Tree
function generate_decision_tree(rootgamestate, maxdepth)
	#Make Tree struct
	decisiontree = Tree(rootgamestate)
	decisiontree.root.direction = "root"
	#Generate the Nodes.
	make_all_moves!(decisiontree.root, maxdepth)

	#Find the highest weighted Node
	sum_weights!(decisiontree.root)

	#Return the tree
	return decisiontree
end


# make_all_moves!(::Node, ::Int64)
# RETURN: None
#@CLEAN - must be a better way to do this...
function make_all_moves!(node::Node, depth)
	if(depth == 0)
		#I am a leaf node, therefore you should find out my weight
			#Case where leaf node is a death node resulting in no gamestate
		if(!isdefined(node, :gamestate))
			return
		else
			node.weight = generate_gamestate_weight(node.gamestate)
			return
		end
	end

	#Generate move nodes for each direction
	if(isdefined(node, :gamestate))
		node.left = generate_move_node(node.gamestate, "left")
		node.right = generate_move_node(node.gamestate, "right")
		node.up = generate_move_node(node.gamestate, "up")
		node.down = generate_move_node(node.gamestate, "down")
		make_all_moves!(node.left, depth-1)
		make_all_moves!(node.right, depth-1)
		make_all_moves!(node.up, depth-1)
		make_all_moves!(node.down, depth-1)
	end

end

# generate_move_node(::GameState, ::String)
# RETURN: ::Node
function generate_move_node(gamestate::GameState, mymove)
	#Create blank Node struct.
	self = Node()
	self.direction = mymove
	# Simulate the gamestate by one move then replace old gamestate.
	newgamestate = simulate_one_move(gamestate, mymove)

	#This move resulted in a death, high negative weight.
	if(newgamestate == -1)
		self.weight=-10000
		return self
	end
	self.gamestate = newgamestate
	return self
end

# generate_gamestate_weight(::GameState)
# RETURN: ::Int64
function generate_gamestate_weight(gamestate)
	return gamestate.you.health
end

# sum_weights!(::Node)
# RETURN: None
function sum_weights!(node::Node)
	if(node.weight < 11111)
		return node.weight
	end
	node.weight = 0

	if(isdefined(node, :left))
		node.weight += sum_weights!(node.left)
	end

	if(isdefined(node, :right))
		node.weight += sum_weights!(node.right)
	end
	
	if(isdefined(node, :up))
		node.weight += sum_weights!(node.up)
	end

	if(isdefined(node, :down))
		node.weight += sum_weights!(node.down)
	end

	return node.weight
end

#Returns the best move of the tree root as a string
function best_move(tree::Tree)
	maxweight = -1111111111
	maxmove = "dead"
	if(tree.root.left.weight > maxweight && tree.root.left.weight != -10000)
		maxweight = tree.root.left.weight
		maxmove = "left"
	end
	if(tree.root.right.weight > maxweight && tree.root.right.weight != -10000)
		maxweight = tree.root.right.weight
		maxmove = "right"
	end
	if(tree.root.up.weight > maxweight && tree.root.up.weight != -10000)
		maxweight = tree.root.up.weight
		maxmove = "up"
	end
	if(tree.root.down.weight > maxweight && tree.root.down.weight != -10000)
		maxweight = tree.root.down.weight
		maxmove = "down"
	end
	return maxmove
end

##### END #####


##### Printing #####
#@FIX printing doesnt work really at all anymore, must be someway to make this pretty.
function print_tree(tree::Tree)
	print_tree_util(tree.root, 0)
end

function print_tree_util(node::Node, depth)
	if(!isdefined(node, :left) && !isdefined(node, :right) && !isdefined(node, :up) && !isdefined(node, :down))
		print(repeat("    ", depth))
		@printf("Leaf Direction: %s, Weight: %f\n", node.direction, node.weight)
		return
	end
	print(repeat("    ", depth))
	@printf("Node Direction: %s, Weight: %f\n", node.direction, node.weight)
	if(isdefined(node, :left))
		print(repeat("    ", depth))
		print_tree_util(node.left, depth+1)
	end
	if(isdefined(node, :right))
		print(repeat("    ", depth))
		print_tree_util(node.right, depth+1)
	end
	if(isdefined(node, :up))
		print(repeat("    ", depth))
		print_tree_util(node.up, depth+1)
	end
	if(isdefined(node, :down))
		print(repeat("    ", depth))
		print_tree_util(node.down, depth+1)
	end

end

##### END #####