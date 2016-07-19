local enums = {}

enums.Heuristic = {
	Manhattan = 'manhattanDistance', -- usually overestimates
	Diagonal = 'diagonalDistance', -- good compromise for 8 directions
	Euclidean = 'euclideanDistance', -- almost always underestimates
}

return enums
