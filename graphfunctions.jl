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


function mapXYtoFloat(xytuple, boardsize)
	space = range(1.01, stop=1.99, length=boardsize+1)
	nx = space[xytuple.x+1]
	ny = space[xytuple.y+1]
	return (x=nx, y=ny)
end


function distanceOfTwoPoints(point1, point2)
	return abs(point1.x - point2.x) + abs(point1.y - point2.y)
end


#TODO Last snake gets points of equidistance, this needs to be
#fixed for accurate heuristic evaluation
function generateClosestPointsDict(gamestate)
	closestpoints = Dict{Integer, Dict{NamedTuple, Integer}}()
	for snake in 1:length(gamestate.board.snakes)
		closestpoints[snake] = Dict{NamedTuple, Integer}()
	end
	for snake in 1:length(gamestate.board.snakes)
		for i in 0:gamestate.board.width-1
			for j in 0:gamestate.board.height-1
				pointmatch = false
				for enemysnake in 1:length(gamestate.board.snakes)
					if snake != enemysnake
						if haskey(closestpoints[enemysnake], (x=i, y=j)) 
							pointmatch = true
							if distanceOfTwoPoints(gamestate.board.snakes[snake].body[1], (x=i, y=j)) < closestpoints[enemysnake][(x=i, y=j)]
								closestpoints[snake][(x=i, y=j)] = distanceOfTwoPoints(gamestate.board.snakes[snake].body[1], (x=i, y=j))
								delete!(closestpoints[enemysnake], (x=i, y=j))
							elseif distanceOfTwoPoints(gamestate.board.snakes[snake].body[1], (x=i, y=j)) == closestpoints[enemysnake][(x=i, y=j)]
								delete!(closestpoints[enemysnake], (x=i, y=j))
							end
						end
					end
				end
				#TODO Problem is here, because we delete equidistant poitns from both snake dicts
				# the last snake has point match set to false, allowing it to gain the point
				if !pointmatch
					closestpoints[snake][(x=i, y=j)] = distanceOfTwoPoints(gamestate.board.snakes[snake].body[1], (x=i, y=j))
				end
			end
		end
	end
	return closestpoints


end

