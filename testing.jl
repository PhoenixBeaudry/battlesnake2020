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

	testdata = "{\"game\":{\"id\":\"402952c4-ad2d-4d4f-9421-4dc0caed0f57\"},\"turn\":32,\"board\":{\"height\":11,\"width\":11,\"food\":[{\"x\":2,\"y\":10},{\"x\":10,\"y\":2},{\"x\":0,\"y\":5}],\"snakes\":[{\"id\":\"gs_wqBQBhdSv77hKMrPdD9YJBBP\",\"name\":\"AhmedNSidd / Samaritan-2\",\"health\":91,\"body\":[{\"x\":3,\"y\":5},{\"x\":4,\"y\":5},{\"x\":4,\"y\":4},{\"x\":4,\"y\":3},{\"x\":4,\"y\":2},{\"x\":5,\"y\":2},{\"x\":6,\"y\":2},{\"x\":6,\"y\":3}]},{\"id\":\"gs_YXtbWPXj4773Tp6tCmVycJrJ\",\"name\":\"PhoenixBeaudry / Test\",\"health\":68,\"body\":[{\"x\":4,\"y\":6},{\"x\":4,\"y\":7},{\"x\":5,\"y\":7}]}]},\"you\":{\"id\":\"gs_YXtbWPXj4773Tp6tCmVycJrJ\",\"name\":\"PhoenixBeaudry / Test\",\"health\":68,\"body\":[{\"x\":4,\"y\":6},{\"x\":4,\"y\":7},{\"x\":5,\"y\":7}]}}"
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
#print_tree(tree)
#print(best_move(tree))
