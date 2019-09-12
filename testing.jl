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

	testdata = "{\"game\":{\"id\":\"2891a981-230d-47dc-be47-9840c902d393\"},\"turn\":37,\"board\":{\"height\":11,\"width\":11,\"food\":[{\"x\":0,\"y\":5},{\"x\":3,\"y\":10}],\"snakes\":[{\"id\":\"gs_qCDXP8QYJF7dHfRwq4tggBYQ\",\"name\":\"unapersona / Glotona\",\"health\":99,\"body\":[{\"x\":4,\"y\":3},{\"x\":4,\"y\":2},{\"x\":5,\"y\":2},{\"x\":5,\"y\":1},{\"x\":6,\"y\":1},{\"x\":6,\"y\":2},{\"x\":6,\"y\":3},{\"x\":6,\"y\":4},{\"x\":6,\"y\":5},{\"x\":6,\"y\":6},{\"x\":6,\"y\":7}]},{\"id\":\"gs_Rmx7bMmxtKcKKvXvPC7dm76f\",\"name\":\"PhoenixBeaudry / Test\",\"health\":63,\"body\":[{\"x\":5,\"y\":4},{\"x\":5,\"y\":5},{\"x\":5,\"y\":6}]}]},\"you\":{\"id\":\"gs_Rmx7bMmxtKcKKvXvPC7dm76f\",\"name\":\"PhoenixBeaudry / Test\",\"health\":63,\"body\":[{\"x\":5,\"y\":4},{\"x\":5,\"y\":5},{\"x\":5,\"y\":6}]}}"
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
