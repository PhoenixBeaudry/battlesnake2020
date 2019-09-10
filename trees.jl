using Printf
include("grids.jl")
include("gamestate.jl")

##### TODOS #####

#@IDEA Use Julia Multithreading to generate nodes and weights (@spawn).

#@REMIND Only leaf nodes contribute to weight, at least I think thats best.

#@FIX Currently the weight does not take into account running into enemy snakes
# or yourself as deaths, only being forced into a wall

##### END #####

##### Data Structures #####
mutable struct Node
	gamestate::GameState
	weight::Int64
	id
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
# RETURN: Tree
function generate_decision_tree(rootgamestate, maxdepth)
	#Make Tree struct
	decisiontree = Tree(rootgamestate)

	#Generate the Nodes.
	make_all_moves!(decisiontree.root, maxdepth)

	#Find the highest weighted Node
	sum_weights!(decisiontree.root)

	#Return the tree
	return decisiontree
end


# make_all_moves!(::Node, ::Int64)
# RETURN: None.
#@CLEAN - must be a better way to do this...
function make_all_moves!(node::Node, depth)
	if(depth == 0)
		return
	end
	if(isdefined(node, :gamestate))
		node.left = generate_move_node(node.gamestate, "left")
	end

	if(isdefined(node, :gamestate))
		node.right = generate_move_node(node.gamestate, "right")
	end

	if(isdefined(node, :gamestate))
		node.up = generate_move_node(node.gamestate, "up")
	end

	if(isdefined(node, :gamestate))
		node.down = generate_move_node(node.gamestate, "down")
	end

	if(isdefined(node, :left))
		make_all_moves!(node.left, depth-1)
	end

	if(isdefined(node, :right))
		make_all_moves!(node.right, depth-1)
	end
	
	if(isdefined(node, :up))
		make_all_moves!(node.up, depth-1)
	end

	if(isdefined(node, :down))
		make_all_moves!(node.down, depth-1)
	end

end

# generate_move_node(::GameState, ::String)
# RETURN: Node
function generate_move_node(gamestate::GameState, mymove)
	#Create blank Node struct.
	self = Node()
	# Simulate the gamestate by one move then replace old gamestate.
	newgamestate = simulate_one_move(gamestate, mymove)
	if(newgamestate == -1)
		self.weight=-10000
		self.id = 0
		return self
	end
	self.gamestate = newgamestate

	#@FIX this probably shouldnt be here but Ill leave it for now.
	self.weight = generate_gamestate_weight(self.gamestate)
	self.id = 0
	return self
end

# generate_gamestate_weight(::GameState)
# RETURN: Int64
function generate_gamestate_weight(gamestate)
	return 0
end

# sum_weights!(::Node)
# RETURN: None
# @IDEA This is where gamestate weight should be evaled maybe.
function sum_weights!(node::Node)
	if(isdefined(node, :weight))
		return node.weight
	end

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

	return
end

#Returns the best move of the tree root as a string
function best_move(tree::Tree)
	maxweight = tree.root.left.weight
	maxmove = "left"
	if(tree.root.right.weight > maxweight)
		maxweight = tree.root.right.weight
		maxmove = "right"
	end
	if(tree.root.up.weight > maxweight)
		maxweight = tree.root.up.weight
		maxmove = "up"
	end
	if(tree.root.down.weight > maxweight)
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
	if(!isdefined(node, :left))
		print(repeat("    ", depth))
		@printf("Node:%f Children: None\n", node.weight)
		return
	end
	@printf("Node:%f Children:%f,%f,%f,%f\n", node.weight, node.left.weight, node.right.weight, node.up.weight, node.down.weight)
	print(repeat("    ", depth))
	print_tree_util(node.left, depth+1)
	print(repeat("    ", depth))
	print_tree_util(node.right, depth+1)
	print(repeat("    ", depth))
	print_tree_util(node.up, depth+1)
	print(repeat("    ", depth))
	print_tree_util(node.down, depth+1)
end

##### END #####