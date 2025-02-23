class_name AStar

class Solver:
	'''
	Times:
		V1 (basic):
			Empty: 114
			Long: 20
			One Path: 2
		
		V2 (reverse unvisited traversal):
			Empty: 60 (but wrong)
			Long: 20
			One Path: 2
		
		V3 (lowest cost first, cost is dx+dy):
			Empty: 5 (but wrong)
			Long: 22
			One Path: 2
	'''
	class Cell:
		var pos: Vector2
		var previous: Cell
		var cost: int
		
		func _init(cellPos:Vector2, previousCell: Cell, goal: Vector2) -> void:
			pos = cellPos
			previous = previousCell
			cost = abs(goal.x - pos.x + goal.y - pos.y)
		
		func get_position() -> Vector2:
			return pos
		
		func get_previous() -> Cell:
			return previous
		
		func get_cost() -> int:
			return cost
		
	enum movementType {
		CARDINAL,
		DIAGONAL,
		OMNIDIRECTIONAL
	}
	
	#var maze: AStarMaze
	#var unvisited: PackedVector2Array
	#var visited: Array[Cell]
	var directions: Array[Vector2]
	var solveTime: int
	
	func _init(movement: movementType) -> void:
		switch_movement(movement)
	
	func switch_movement(movement: movementType) -> void:
		match movement:
			movementType.CARDINAL:
				directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)] # Cardinal
			movementType.DIAGONAL:
				directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)] # Diagonals
			movementType.OMNIDIRECTIONAL:
				directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)] # Cardinal + Diagonal
		
	func solve_maze(maze: AStar.Maze) -> PackedVector2Array:
		var start: Vector2 = maze.get_start()
		var goal: Vector2 = maze.get_end()
		if (start == goal):
			return []
			
		var unvisited: Array[Cell] = [Cell.new(start, null, goal)]
		var visited: Array[Cell] = []
		
		while (!unvisited.is_empty()):
			var lowestCost: Cell = unvisited.pop_at(get_lowest_cost(unvisited))
			if (lowestCost.get_position() == goal): # Found path
				var path: PackedVector2Array = [unvisited.back().get_position()]
				var nextCell = unvisited.back().get_previous()
				
				while (nextCell != null):
					path.append(nextCell.get_position())
					nextCell = nextCell.get_previous()
				
				return path
			
			var neighbors: Array[Cell] = get_neighbors(lowestCost, maze, visited, goal)
			unvisited.append_array(neighbors)
			visited.append_array(neighbors)
		
		return []
	
	func get_neighbors(cell: Cell, maze: AStar.Maze, visited: Array[Cell], goal: Vector2) -> Array[Cell]:
		var neighbors: Array[Cell] = []
		var mazeSize: Vector2 = maze.get_size()
		
		for dir in directions:
			var newPos: Vector2 = cell.get_position() + dir
			if (newPos.x >= 0 && newPos.y >= 0 && newPos.x < mazeSize.x && newPos.y < mazeSize.y): # Make sure newPos exists in maze
				if (maze.is_tile_empty(newPos.x, newPos.y)): # Check if tile is empty
					var alreadyVisited: bool = false
					for visitedCell in visited:
						if (newPos == visitedCell.get_position()):
							alreadyVisited = true
							break
					if (!alreadyVisited): # Check if unvisited
						neighbors.append(Cell.new(newPos, cell, goal))
		
		return neighbors
	
	func get_lowest_cost(cells: Array[Cell]) -> int:
		var lowestCost: int = 0
		for index in range(1, cells.size()):
			if cells[index].get_cost() < cells[lowestCost].get_cost():
				lowestCost = index
		return lowestCost



class Maze:
	var gridSize: Vector2
	var grid: PackedInt32Array
	
	func _init(size = Vector2(10, 10)) -> void:
		gridSize = size
		grid = []
		grid.resize(gridSize.x * gridSize.y)
		grid.set(0, 2)
		grid.set(grid.size()-1, 3)
	
	func change_tile(x: int, y: int, newTile: int) -> void:
		var index: int = y*gridSize.x + x
		grid[index] = newTile # Flip tile state
	
	func is_tile_empty(x: int, y: int) -> bool:
		return grid[y*gridSize.x + x] != 1
	
	func get_tile_type(x: int, y: int) -> int:
		return grid[y*gridSize.x + x]
	
	func get_start() -> Vector2:
		for tile in len(grid):
			if (grid[tile] == 2):
				return Vector2(tile%int(gridSize.x), floor(tile/gridSize.x))
		return Vector2.ZERO
	
	func get_end() -> Vector2:
		for tile in len(grid):
			if (grid[tile] == 3):
				return Vector2(tile%int(gridSize.x), floor(tile/gridSize.x))
		return Vector2.ZERO
	
	func get_size() -> Vector2:
		return gridSize
	
	func set_maze(newGrid: PackedInt32Array) -> void:
		assert(newGrid.size() == grid.size(), "Invalid grid size")
		grid = newGrid
