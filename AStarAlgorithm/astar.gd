class_name AStar
##class_name AStar
## class Solver
	## class Cell
		##vars
		##funcs
	## enuns
	##vars
	##funcs
##class Maze

'''
astar pseudocode
F = G + H
	F is the total cost of the node.
	G is the distance between the current node and the start node.
	H is the heuristic — estimated distance from the current node to the end node.
		typically Manhattan style = number of cells horizontal + number of cell vertical.
		
1. Add the starting square (or node) to the open list.

2. Repeat the following:

	A) Look for the lowest F cost square on the open list. We refer to this as the current square.

	B). Switch it to the closed list.

	C) For each of the 8 squares adjacent to this current square …

		If it is not walkable or if it is on the closed list, ignore it. Otherwise do the following.
		If it isn’t on the open list, add it to the open list. Make the current square the parent of
			this square. Record the F, G, and H costs of the square.
		If it is on the open list already, check to see if this path to that square is better, 
			using G cost as the measure. A lower G cost means that this is a better path. If so, 
			change the parent of the square to the current square, and recalculate the G and F 
			scores of the square. If you are keeping your open list sorted by F score, you may need 
			to resort the list to account for the change.

D) Stop when you:

	Add the target square to the closed list, in which case the path has been found, or
	Fail to find the target square, and the open list is empty. In this case, there is no path.

3. Save the path. Working backwards from the target square, go from each square to its 
	parent square until you reach the starting square. That is your path.
	
PSEUDOCODE
// A* (star) Pathfinding

// Initialize both open and closed list
let the openList equal empty list of nodes
let the closedList equal empty list of nodes

// Add the start node
put the startNode on the openList (leave it's f at zero)

// Loop until you find the end
while the openList is not empty    

	// Get the current node
	let the currentNode equal the node with the least f value
	remove the currentNode from the openList
	add the currentNode to the closedList    
	// Found the goal
	if currentNode is the goal
		Congratz! You've found the end! Backtrack to get path    
	// Generate children
	let the children of the currentNode equal the adjacent nodes
	
		for each child in the children        
		// Child is on the closedList
		if child is in the closedList
		continue to beginning of for loop 
					   
		// Create the f, g, and h values
		child.g = currentNode.g + distance between child and current
		child.h = distance from child to end
		child.f = child.g + child.h
						
		// Child is already in openList
		if child.position is in the openList's nodes positions
			if the child.g is higher than the openList node's g
				continue to beginning of for loop        
		// Add the child to the openList
		add the child to the openList
'''

class Solver:
	## Class Solver
		## class Cell
	## enum movementType
	## enum costCalculation
	## var directions: Array[Vector2]
	## var chosenCalculation: costCalculation
	## var solveTime: int
	## func _init
	## func change_movement
	## func change_cost_calculation
	## func solve_maze
	## func get_neighbors
	## func get_lowest_cost
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
	##Inner Class: Solver.Cell: 
	##var pos: Vector2, 
	##var previous: Cell, 
	## var cost:int
	##func _init
	##func get_position
	##func get_previous
	##func change_previous
	##func get_cost
	
		var pos: Vector2
		var previous: Cell
		var cost: int
		
		##_init is for class initialisation and it is called when the class is created
		func _init(cellPos:Vector2, previousCell: Cell, goal: Vector2, costCalc: costCalculation) -> void:
			print_rich("[font_size=15][color=pink]Solver.Cell._init ENTERED, cellPos = ", cellPos,"; previousCell = ", previousCell, "; goal = ", goal, "; costCalc = ", costCalc)
			pos = cellPos
			previous = previousCell
			match costCalc:
				costCalculation.DXDY:
					cost = abs(goal.x - pos.x + goal.y - pos.y)
				costCalculation.CUMULATIVE:
					cost = abs(goal.x - pos.x + goal.y - pos.y)
					if (previous != null):
						cost += previous.get_cost()
			print_rich("[font_size=15][color=pink]Solver.Cell._init FINISHED, pos = ", pos,"; previous = ", previous, "; goal = ", goal, "; costCalc = ", costCalc)
		
		func get_position() -> Vector2:
			print_rich("[font_size=15][color=teal]Solver.Cell.get_position ENTERED / RETURN: pos = ", pos)
			return pos
		
		func get_previous() -> Cell:
			return previous
		
		func change_previous(newPrevious: Cell) -> void:
			previous = newPrevious
		
		func get_cost() -> int:
			print_rich("[font_size=15][color=GREEN]Solver.Cell.get_cost ENTERED, RETURN cost = ", cost)
			return cost
	
	
	enum movementType {
		CARDINAL,
		DIAGONAL,
		OMNIDIRECTIONAL
	}
	
	enum costCalculation {
		DXDY,
		CUMULATIVE
	}
	
	var directions: Array[Vector2]
	var chosenCalculation: costCalculation
	var solveTime: int
	
	func _init(movement: movementType, costCalc: costCalculation) -> void:
		change_movement(movement)
		change_cost_calculation(costCalc)
	
	func change_movement(movement: movementType) -> void:
		match movement:
			movementType.CARDINAL:
				directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)] # Cardinal
			movementType.DIAGONAL:
				directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)] # Diagonals
			movementType.OMNIDIRECTIONAL:
				directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)] # Cardinal + Diagonal
	
	func change_cost_calculation(costCalc: costCalculation) -> void:
		chosenCalculation = costCalc
		
	func solve_maze(maze: AStar.Maze) -> PackedVector2Array:
		print_rich("[font_size=15][color=red] SOLVE_MAZE.  maze = ", maze)
		var start: Vector2 = maze.get_start()
		var goal: Vector2 = maze.get_end()
		print("		start = ", start, "; goal = ", goal)
		if (start == goal):
			#print_rich("[font_size=15][color=GREEN] start == goal")
			return []
			
		var unvisited: Array[Cell] = [Cell.new(start, null, goal, chosenCalculation)]
		var visited: Array[Cell] = []
		#for i in unvisited:
			#print("i = ", i , "; unvisited = ", unvisited)
		#print("visited = ", visited)
		while (!unvisited.is_empty()):
			##lowestCost is a RefCounted
			##get_lowest_cost(unvisited) returns an integer
			## = unvisited.pop_at(integer)
			##so lowestCost is type Cell - even tho is has the same name as the index
			var lowestCost: Cell = unvisited.pop_at(get_lowest_cost(unvisited))
			#print("lowestCost = ", lowestCost)
			if (lowestCost.get_position() == goal): # Found path
				print_rich("[font_size=15][color=orange][wave] GOAL!!!")
				var path: PackedVector2Array = [lowestCost.get_position()]
				var nextCell = lowestCost
				
				##build the final path
				while (nextCell != null):
					##nextCell is a RefCounted
					#print("nextCell = ", nextCell)
					path.append(nextCell.get_position())
					nextCell = nextCell.get_previous()
				#print("psth = ", path)
				return path
			
			var neighbors: Array[Cell] = get_neighbors(lowestCost, maze, visited, goal)
			unvisited.append_array(neighbors)
			visited.append_array(neighbors)
		
		return []
	
	func get_neighbors(cell: Cell, maze: AStar.Maze, visited: Array[Cell], goal: Vector2) -> Array[Cell]:
		print_rich("[font_size=15][color=cyan]Solver.get_neighbors ENTERED")
		var neighbors: Array[Cell] = []
		var mazeSize: Vector2 = maze.get_size()
		print_rich("[font_size=15][color=cyan]Solver.get_neighbors: cell =[color=yellow] ", cell,"[color=cyan]; maze = ", maze, "; [color=salmon]visited = ", visited, ";[color=cyan] goal = ", goal)
		for dir in directions:
			var newPos: Vector2 = cell.get_position() + dir
			if (newPos.x >= 0 && newPos.y >= 0 && newPos.x < mazeSize.x && newPos.y < mazeSize.y): # Make sure newPos exists in maze
				if (maze.is_tile_empty(newPos.x, newPos.y)): # Check if tile is empty
					var alreadyVisited: bool = false
					for visitedCell in visited:
						if (newPos == visitedCell.get_position()):
							#if (cell.get_cost() < visitedCell.get_previous().get_cost()):
							#	visitedCell.change_previous(cell)
							alreadyVisited = true
							break
					if (!alreadyVisited): # Check if unvisited
						neighbors.append(Cell.new(newPos, cell, goal, chosenCalculation))
		print_rich("[font_size=15][color=CYAN]Solver.get_neighbors:[color=Blueviolet]RETURN neighbors =[color=yellow] ", neighbors)
		return neighbors
	
	func get_lowest_cost(cells: Array[Cell]) -> int:
		print_rich("[font_size=15][color=peachpuff]func get_lowest_cost Entered, cells = ", cells)
		var lowestCostIndex: int = 0
		for index in range(1, cells.size()):
			#print("		cells[",index,"] = ", cells[index])
			if cells[index].get_cost() < cells[lowestCostIndex].get_cost():
				print_rich("[font_size=15][color=silver]Solver.get_lowest_cost: cells index[",index,"].get_cost() = ", cells[index].get_cost() )
				print_rich("[font_size=15][color=gold]Solver.get_lowest_cost: cells lowestCostIndex[",lowestCostIndex,"].get_cost() = ", cells[lowestCostIndex].get_cost() )
				lowestCostIndex = index
				
		print_rich("[font_size=15][color=peachpuff]Solver.get_lowest_cost:RETURN: lowestCostIndex = ", lowestCostIndex)
		##lowestCostIndex is an integer - likely an index
		return lowestCostIndex



class Maze:
## class Maze
## var gridSize: Vector2
## var grid: PackedInt32Array
## func _init
## func change_tile
## func is_tile_empty
## func get_tile_type
## func get_start
## func get_end
## func set_size
## func get_size
## func set_maze
##
##
	var gridSize: Vector2
	var grid: PackedInt32Array
	
	func _init(size = Vector2(10, 10)) -> void:
		print_rich("[font_size=15][color=Navajowhite]Maze._init ENTERED: size = ", size)
		gridSize = size
		grid = []
		grid.resize(gridSize.x * gridSize.y)
		grid.set(0, 2)
		grid.set(grid.size()-1, 3)
		print_rich("[font_size=15][color=Navajowhite]Maze._init FINISHED: gridSize = ", gridSize, "; grid = ", grid)
	
	func change_tile(x: int, y: int, newTile: int) -> void:
		var index: int = y*gridSize.x + x
		grid[index] = newTile # Flip tile state
	
	func is_tile_empty(x: int, y: int) -> bool:
		print_rich("[font_size=15][color=DODGERBLUE]Maze.is_tile_empty ENTERED/ RETURN <grid[y*gridSize.x + x] != 1>  grid[",y,"*",gridSize.x," + ",x,"] != 1:", grid[y*gridSize.x + x] != 1)
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
	
	func set_size(x: int, y: int):
		gridSize = Vector2(x, y)
		grid.resize(x*y)
	
	func get_size() -> Vector2:
		return gridSize
	
	func set_maze(newGrid: PackedInt32Array) -> void:
		assert(newGrid.size() == grid.size(), "Invalid grid size")
		grid = newGrid
