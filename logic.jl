using LightGraphs, MetaGraphs

mutable struct GameState
	game
	turn
	board
	you
	graph::Union{Nothing, MetaGraph}
	GameState() = new(0, 0, 0, 0)
	GameState(game, turn, board, you) = new(game, turn, board, you)
	GameState(oldgamestate, graph) = new(oldgamestate.game, oldgamestate.turn, oldgamestate.board, oldgamestate.you, graph)
end