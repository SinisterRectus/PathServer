local enums = {}

enums.Heuristic = {
	Manhattan = 'manhattanDistance', -- usually overestimates
	Diagonal = 'diagonalDistance', -- good compromise for 8 directions
	Euclidean = 'euclideanDistance', -- almost always underestimates
}

enums.Direction = {
	Forward = 1,
	Backward = 2,
	Left = 3,
	Right = 4,
	ForwardLeft = 5,
	BackWardRight = 6,
	ForwardRight = 7,
	BackwardLeft = 8,
}

return enums
