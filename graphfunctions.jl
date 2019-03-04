
#tupleToGraphIndex
#Takes the x, y value in a Tuple and converts it
#to the required index in the MetaGraph
#TODO Dont assume square graph
function tupleToGraphIndex(tuple, boardsize)
	x = tuple.x + 1
	y = tuple.y
	return (x + y*boardsize)
end

