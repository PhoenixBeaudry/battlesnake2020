using VoronoiDelaunay
using JSON2
include("graphfunctions.jl")
include("logic.jl")
boardsize = 11

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

closestpointdict = generateClosestPointsDict(currentGameState)


using Plots
s1xs = Int64[]
s1ys = Int64[]
anno1 = String[]
for point in keys(closestpointdict[1])
	push!(s1xs, point.x)
	push!(s1ys, point.y)
	push!(anno1, string(closestpointdict[1][point]))
end

s2xs = Int64[]
s2ys = Int64[]
anno2 = String[]
for point in keys(closestpointdict[2])
	push!(s2xs, point.x)
	push!(s2ys, point.y)
	push!(anno2, string(closestpointdict[2][point]))
end

s3xs = Int64[]
s3ys = Int64[]
anno3 = String[]
for point in keys(closestpointdict[3])
	push!(s3xs, point.x)
	push!(s3ys, point.y)
	push!(anno3, string(closestpointdict[3][point]))
end

scatter(s1xs, s1ys, series_annotations=anno1, markercolor = :green, size=(800,800))
scatter!(s2xs, s2ys, series_annotations=anno2,  markercolor = :blue)
scatter!(s3xs, s3ys, series_annotations=anno3, markercolor = :red)
savefig("plottesting.png")




#=
tess = DelaunayTessellation()

point1 = mapXYtoFloat((x=0,y=0), boardsize)
point2 = mapXYtoFloat((x=10,y=10), boardsize)
#point3 = mapXYtoFloat((x=3,y=3), boardsize)
#point4 = mapXYtoFloat((x=4,y=4), boardsize)
println(point1)
println(point2)
#println(point3)
#println(point4)
push!(tess, Point(point1.x, point1.y))
push!(tess, Point(point2.x, point2.y))
#push!(tess, Point(point3.x, point3.y))
#push!(tess, Point(point4.x, point4.y))
pointtest = mapXYtoFloat((x=2,y=2), boardsize)
println(mapXYtoFloat((x=2,y=2), boardsize))
println(locate(tess, Point(pointtest.x, pointtest.y)))

x, y = getplotxy(voronoiedges(tess))
using Gadfly
set_default_plot_size(15cm, 15cm)
plot(x=x, y=y, Geom.path, Scale.x_continuous(minvalue=1.0, maxvalue=2.0), Scale.y_continuous(minvalue=1.0, maxvalue=2.0))

=#