#Testing
using JSON2
using Plots
include("grids.jl")
include("trees.jl")
include("gamestate.jl")
include("functionstrategies.jl")

function testEnv()
	testdata = "{
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
    plot(xs, ys, reverse(test, dims=2), seriestype=:heatmap, match_dimensions=true, yflip=true)
    savefig(filename)
end


currentGameState = testEnv()
tree = generate_decision_tree(currentGameState, 3)
print(best_move(tree))
#plotThis(currentGameState, "file1.png")