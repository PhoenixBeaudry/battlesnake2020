#Testing
using JSON2
using Plots
include("grids.jl")
include("trees.jl")
include("gamestate.jl")
include("functionstrategies.jl")

function testEnv()
	testdata2 = "{
	  \"game\": {
	    \"id\": \"game-id-string\"
	  },
	  \"turn\": 4,
	  \"board\": {
	    \"height\": 11,
	    \"width\": 11,
	    \"food\": [
	      {
	        \"x\": 1,
	        \"y\": 3
	      }
	    ],
	    \"snakes\": [
	      {
	        \"id\": \"snake-id-string\",
	        \"name\": \"Sneky Snek\",
	        \"health\": 90,
	        \"body\": [
	          {
	            \"x\": 0,
	            \"y\": 0
	          }
	        ]
	      },
				{
	        \"id\": \"snake-id-string2\",
	        \"name\": \"Sneky Snek2\",
	        \"health\": 90,
	        \"body\": [
	          {
	            \"x\": 10,
	            \"y\": 10
	          }
	        ]
	      },
	      {
	        \"id\": \"snake-id-string3\",
	        \"name\": \"Sneky Snek3\",
	        \"health\": 90,
	        \"body\": [
	          {
	            \"x\": 0,
	            \"y\": 10
	          }
	        ]
	      }
	    ]
	  },
	  \"you\": {
	    \"id\": \"snake-id-string\",
	    \"name\": \"Sneky Snek\",
	    \"health\": 90,
	    \"body\": [
	      {
	        \"x\": 0,
	        \"y\": 0
	      }
	    ]
	  }
	}"

	testdata = "{\"game\":{\"id\":\"4b7a841a-f87c-4d79-b08f-2782d6a836a6\"},\"turn\":2,\"board\":{\"height\":11,\"width\":11,\"food\":[{\"x\":9,\"y\":4},{\"x\":3,\"y\":2},{\"x\":7,\"y\":6},{\"x\":6,\"y\":6},{\"x\":0,\"y\":3}],\"snakes\":[{\"id\":\"gs_YjHTJtC6gXGwk6kFHcYxk7H6\",\"name\":\"jeremysnell / Gib Rattler\",\"health\":98,\"body\":[{\"x\":0,\"y\":2},{\"x\":1,\"y\":2},{\"x\":1,\"y\":1}]},{\"id\":\"gs_3VYwmpr9H64QkKdDXjVV7txT\",\"name\":\"Petah / Aldo\",\"health\":98,\"body\":[{\"x\":9,\"y\":7},{\"x\":9,\"y\":8},{\"x\":9,\"y\":9}]},{\"id\":\"gs_rCPx9pFXDgfRJj3fdy8ftjxQ\",\"name\":\"AndrewRozendal / snaples\",\"health\":98,\"body\":[{\"x\":1,\"y\":7},{\"x\":1,\"y\":8},{\"x\":1,\"y\":9}]},{\"id\":\"gs_gXkJbYxJj4XbF9XjvMxHKbkM\",\"name\":\"PhoenixBeaudry / Test\",\"health\":98,\"body\":[{\"x\":4,\"y\":2},{\"x\":5,\"y\":2},{\"x\":5,\"y\":1}]}]},\"you\":{\"id\":\"gs_gXkJbYxJj4XbF9XjvMxHKbkM\",\"name\":\"PhoenixBeaudry / Test\",\"health\":98,\"body\":[{\"x\":4,\"y\":2},{\"x\":5,\"y\":2},{\"x\":5,\"y\":1}]}}"
	currentGameState = JSON2.read(testdata, GameState)
	reformat_gamestate!(currentGameState)
	generate_gamestate_board!(currentGameState)
	return(currentGameState)
end

function plotThis(gamestate, filename)
	test = fill(0.0, gamestate.board.height, gamestate.board.height)
	for i in eachindex(gamestate.matrix)
		test[i] = gamestate.matrix[i].weight
	end
	xs = [string("x", i) for i = 1:11]
	ys = [string("y", i) for i = 1:11]
    plot(xs, ys, reverse(test, dims=2), seriestype=:heatmap, match_dimensions=true, yflip=true)
    savefig(filename)
end


currentGameState = testEnv()
tree = generate_decision_tree(currentGameState, 4)
print(best_move(tree))
