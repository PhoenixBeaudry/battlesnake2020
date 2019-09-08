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

	testdata="{\"game\":{\"id\":\"2a910ae8-3159-4885-ae95-193fbc9708d2\"},\"turn\":4,\"board\":{\"height\":11,\"width\":11,\"food\":[{\"x\":8,\"y\":6},{\"x\":7,\"y\":9}],\"snakes\":[{\"id\":\"gs_4hBvjVCPCWDdxjXGd6mwTptR\",\"name\":\"LayCraft / Heel Bruiser\",\"health\":96,\"body\":[{\"x\":0,\"y\":4},{\"x\":0,\"y\":3},{\"x\":0,\"y\":2}]},{\"id\":\"gs_BBbH7mcr7PxtBkVQ8vYXpC9C\",\"name\":\"alexandercote / DazzleFrazzle\",\"health\":98,\"body\":[{\"x\":9,\"y\":5},{\"x\":9,\"y\":6},{\"x\":9,\"y\":7},{\"x\":9,\"y\":8},{\"x\":9,\"y\":9}]},{\"id\":\"gs_k6cQBjcBqtRcvMgD9dBJp96M\",\"name\":\"DWBayly / The Great Sandworm of Dune\",\"health\":96,\"body\":[{\"x\":1,\"y\":5},{\"x\":1,\"y\":6},{\"x\":1,\"y\":7}]},{\"id\":\"gs_BtGqqyPTKRt3yBDgxPBXdctT\",\"name\":\"PhoenixBeaudry / Test\",\"health\":96,\"body\":[{\"x\":6,\"y\":0},{\"x\":7,\"y\":0},{\"x\":8,\"y\":0}]}]},\"you\":{\"id\":\"gs_BtGqqyPTKRt3yBDgxPBXdctT\",\"name\":\"PhoenixBeaudry / Test\",\"health\":96,\"body\":[{\"x\":6,\"y\":0},{\"x\":7,\"y\":0},{\"x\":8,\"y\":0}]}}"

	currentGameState = JSON2.read(testdata, GameState)
	reformat_gamestate!(currentGameState)
	generate_gamestate_board!(currentGameState)
	return(currentGameState)
end


#@FIX Plots incorrectly, (0,0) is top left corner
function plotThis(gamestate, filename)
	test = fill(0.0, gamestate.board.height, gamestate.board.height)
	for i in eachindex(gamestate.matrix)
		test[i] = gamestate.matrix[i].weight
	end
	xs = [string("x", i) for i = 1:11]
	ys = [string("y", i) for i = 1:11]
    plot(xs, ys, test, seriestype=:heatmap, match_dimensions=true, yflip=true)
    savefig(filename)
end


currentGameState = testEnv()
println(largest_adjacent_weight_dir(currentGameState.you.body[1], currentGameState))
#print_board(currentGameState)
#plotThis(currentGameState, "file1.png")

#=
moves = simulate_one_move(currentGameState, "up")
plotThis(moves, "file2.png")
moves = simulate_one_move(simulate_one_move(currentGameState, "up"), "up")
plotThis(moves, "file3.png")
moves = simulate_one_move(simulate_one_move(moves = simulate_one_move(simulate_one_move(currentGameState, "up"), "up")
plotThis(moves, "file4.png")
=#