import LightGraphs, MetaGraphs

#tupleToGraphIndex
#Takes the x, y value in a Tuple and converts it
#to the required index in the MetaGraph
#TODO Dont assume square graph
function tupleToGraphIndex(tuple, boardsize)
	x = tuple.x + 1
	y = tuple.y
	return (x + y*boardsize)
end


#graphIndexToTuple
#Converts a graph index into a tuple of x, y
function graphIndexToTuple(index, boardsize)
	nx = (index-1)%boardsize
	ny = div(index-1, boardsize)
	return (x = nx, y = ny)
end


#renameGraphNodes
function renameGraphNodes(graph, boardsize)
	for specificnode in LightGraphs.vertices(graph)
		MetaGraphs.set_prop!(graph, specificnode, :position, graphIndexToTuple(specificnode, boardsize))
	end
end

