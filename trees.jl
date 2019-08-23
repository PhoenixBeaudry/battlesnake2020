include("grids.jl")
include("gamestate.jl")
using Printf
global count = 1

mutable struct Node
	weight::Int64
	gamestate::GameState
	id
	left::Union{Nothing, Node}
	right::Union{Nothing, Node}
	up::Union{Nothing, Node}
	down::Union{Nothing, Node}
	Node(newweight::Int64, id) = new(newweight, id)
	Node(weight::Int64, id, left::Node, right::Node, up::Node, down::Node) = new(weight, id, left, right, up, down)
end


mutable struct Tree
	root::Node
	Tree() = new(Node(0, 0))
end


function sum_weights(node::Node)
	return node.left.weight + node.right.weight + node.up.weight + node.down.weight
end


#Returns the best move of the tree root as a string
#//TODO
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

#generates all child moves based on parent node
#at some point this will be much more complex
#or could move the complexity into the Node constructor 
function make_all_moves!(node::Node, depth)
	global count
	if(depth == 0)
		return
	end
	node.left = Node(2, count)
	count += 1
	node.right = Node(3, count)
	count += 1
	node.up = Node(5, count)
	count += 1
	node.down = Node(7, count)
	count += 1
	make_all_moves!(node.left, depth-1)
	make_all_moves!(node.right, depth-1)
	make_all_moves!(node.up, depth-1)
	make_all_moves!(node.down, depth-1)
end


function generate_decision_tree(state, maxdepth)
	decisiontree = Tree()
	make_all_moves!(decisiontree.root, maxdepth)
	return decisiontree
end


#####Printing#####

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
