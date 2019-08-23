#Strategy Functions

function enemy_decay(depth)
	return -9/(2^depth)
end

function food_decay(depth)
	return 9/(2^depth)
end