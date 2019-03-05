using LightGraphs, MetaGraphs

mutable struct GameState
	game #id::String
	turn #::int
	board #height::int width::int food::TupleArray snakes::TupleArray
	you #id::String name::String health::int body::TupleArray
	graph::Union{Nothing, MetaGraph}
	GameState() = new(0, 0, 0, 0)
	GameState(game, turn, board, you) = new(game, turn, board, you)
	GameState(oldgamestate, graph) = new(oldgamestate.game, oldgamestate.turn, oldgamestate.board, oldgamestate.you, graph)
end

