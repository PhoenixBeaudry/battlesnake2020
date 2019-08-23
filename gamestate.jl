using JSON2
mutable struct GameState
	game #id::String
	turn #::int
	board #height::int width::int food::TupleArray snakes::TupleArray(see 'you' for format)
	you #id::String name::String health::int body::TupleArray
	GameState() = new(0, 0, 0, 0)
	GameState(game, turn, board, you) = new(game, turn, board, you)
end
