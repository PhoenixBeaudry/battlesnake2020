
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
	nx = index%boardsize == 0 ? boardsize-1 : index%boardsize - 1
	ny = div(index, boardsize) == 1 || div(index, boardsize) == 0 ?  0 : div(index, boardsize) - 1
	return (x = nx, y = ny)
end

