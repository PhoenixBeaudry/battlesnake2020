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

	testdata = "{\"game\":{\"id\":\"061e5838-78e1-4bc8-be65-2eb4d7371537\"},\"turn\":2,\"board\":{\"height\":11,\"width\":11,\"food\":[{\"x\":2,\"y\":9},{\"x\":6,\"y\":7},{\"x\":0,\"y\":7},{\"x\":8,\"y\":9}],\"snakes\":[{\"id\":\"gs_PyYXfJRtDh3kQbQCSPWVmvcK\",\"name\":\"AhmedNSidd / Samaritan-2\",\"health\":98,\"body\":[{\"x\":1,\"y\":3},{\"x\":1,\"y\":2},{\"x\":1,\"y\":1}]},{\"id\":\"gs_4qrbVxQCCf6BmgPP7TJBFTyX\",\"name\":\"nbw / gorogoro\",\"health\":98,\"body\":[{\"x\":9,\"y\":7},{\"x\":9,\"y\":8},{\"x\":9,\"y\":9}]},{\"id\":\"gs_VRFQMB6Hd6qHqGQdqHKtthXT\",\"name\":\"JoshLarouche / Battlesnake\",\"health\":98,\"body\":[{\"x\":1,\"y\":7},{\"x\":1,\"y\":8},{\"x\":1,\"y\":9}]},{\"id\":\"gs_ccxP46yKwYbKBxkyrFDhR6VK\",\"name\":\"PhoenixBeaudry / Test\",\"health\":98,\"body\":[{\"x\":10,\"y\":0},{\"x\":9,\"y\":0},{\"x\":9,\"y\":1}]}]},\"you\":{\"id\":\"gs_ccxP46yKwYbKBxkyrFDhR6VK\",\"name\":\"PhoenixBeaudry / Test\",\"health\":98,\"body\":[{\"x\":10,\"y\":0},{\"x\":9,\"y\":0},{\"x\":9,\"y\":1}]}}"
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
print_tree(tree)
print(best_move(tree))
