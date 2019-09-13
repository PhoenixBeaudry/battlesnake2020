##### STRUCTS #####
mutable struct Point
	type::String
	weight::Float64
	Point() = new(".", 0.0)
	Point(type::String, weight::Float64) = new(type::String, weight::Float64)
end

mutable struct GameState
	game::NamedTuple{(:id,),Tuple{String}} #id::String
	turn::Int #::int
	board::NamedTuple{(:height, :width, :food, :snakes),Tuple{Int,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1},Array{NamedTuple{(:id, :name, :health, :body),Tuple{String,String,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1}}},1}}} #height::int width::int food::TupleArray snakes::TupleArray(see 'you' for format)
	you::NamedTuple{(:id, :name, :health, :body),Tuple{String,String,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1}}} #id::String name::String health::int body::TupleArray
	matrix::Array{Point,2}
	GameState() = new(0, 0, 0, 0)
	GameState(game::NamedTuple{(:id,),Tuple{String}}, turn::Int, board::NamedTuple{(:height, :width, :food, :snakes),Tuple{Int,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1},Array{NamedTuple{(:id, :name, :health, :body),Tuple{String,String,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1}}},1}}}, you::NamedTuple{(:id, :name, :health, :body),Tuple{String,String,Int,Array{NamedTuple{(:x, :y),Tuple{Int, Int}},1}}}) = new(game, turn, board, you)
end

##### END #####