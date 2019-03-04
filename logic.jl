using LightGraphs, MetaGraphs

mutable struct GameState
	game
	turn
	board
	you
	graph::Union{Nothing, SimpleGraph}
	GameState(game, turn, board, you) = new(game, turn, board, you)
	GameState(oldgamestate, graph) = new(oldgamestate.game, oldgamestate.turn, oldgamestate.board, oldgamestate.you, graph)
end