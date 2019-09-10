using Printf
include("grids.jl")
include("gamestate.jl")

##### TODOS #####

#@IDEA Use Julia Multithreading to generate nodes and weights (@spawn).

#@REMIND Only leaf nodes contribute to weight, at least I think thats best.

##### END #####

##### Data Structures #####
mutable struct Node
	weight::Int64
	gamestate::GameState
	id
	left::Union{Nothing, Node}
	right::Union{Nothing, Node}
	up::Union{Nothing, Node}
	down::Union{Nothing, Node}
	Node() = new()
	Node(newweight::Int64, id) = new(newweight, id)
	Node(weight::Int64, id, left::Node, right::Node, up::Node, down::Node) = new(weight, id, left, right, up, down)
end

mutable struct Tree
	root::Node
	Tree() = new(Node(0, 0))
end

##### END #####

##### Decision Tree #####

# generate_decision_tree(::GameState, ::Int64)
# RETURN: Tree
function generate_decision_tree(rootgamestate, maxdepth)
	decisiontree = Tree()
	make_all_moves!(decisiontree.root, maxdepth)
	return decisiontree
end


# make_all_moves!(::Node, ::Int64)
# RETURN: None.
function make_all_moves!(node::Node, depth)
	if(depth == 0)
		return
	end
	node.left = generate_move_node(node.gamestate, "left")

	node.right = generate_move_node(node.gamestate, "right")

	node.up = generate_move_node(node.gamestate, "up")

	node.down = generate_move_node(node.gamestate, "down")

	make_all_moves!(node.left, depth-1)

	make_all_moves!(node.right, depth-1)

	make_all_moves!(node.up, depth-1)

	make_all_moves!(node.down, depth-1)

end

# generate_move_node(::GameState, ::String)
# RETURN: Node
function generate_move_node(gamestate::GameState, mymove)
	#Create blank Node object.
	self = Node()
	# Simulate the gamestate by one move then replace old gamestate.
	self.gamestate = simulate_one_move(gamestate, mymove)
	self.weight = generate_gamestate_weight(self.gamestate)
	return self
end

# generate_gamestate_weight(::GameState)
# RETURN: Int64
function generate_gamestate_weight(gamestate)
	return 0
end

function sum_weights(node::Node)
	return node.left.weight + node.right.weight + node.up.weight + node.down.weight
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

function print_tree(tree::Tree)
	print_tree_util(tree.root, 0)
end

function print_tree_util(node::Node, depth)
	if(!isdefined(node, :left))
		print(repeat("    ", depth))
		@printf("Node:%f Children: None\n", node.id)
		return
	end
	@printf("Node:%f Children:%f,%f,%f,%f\n", node.id, node.left.id, node.right.id, node.up.id, node.down.id)
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