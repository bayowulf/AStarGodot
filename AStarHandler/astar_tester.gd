extends Node2D

@export_category("Maze")
@export var gridSize: Vector2 = Vector2(10, 10)
@export var tileSize: int = 16
@export var presetsDict: Dictionary = {}

@export_category("Colors")
@export var emptyColor: Color = Color(1.0, 1.0, 1.0) # 0
@export var fillColor: Color = Color(0.0, 0.0, 0.0) # 1
@export var startColor: Color = Color(0.0, 1.0, 0.0) # 2
@export var goalColor: Color = Color(1.0, 1.0, 0.0) # 3
@export var solutionColor: Color = Color(1.0, 0.0, 0.0) # 4
@export var outlineColor: Color = Color(0.5, 0.5, 0.5)

@export_category("Misc")
@export var outlineSize: int = 1

var maze: AStar.Maze
var solver: AStar.Solver
var cachedPath: PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for index in len(presetsDict):
		$CanvasLayer/MazePresets.add_item(presetsDict.keys()[index], index)
		$CanvasLayer/MazePresets.get_popup().set_item_as_radio_checkable(index, false)
	$CanvasLayer/MazePresets.selected = -1
	for index in AStar.Solver.movementType.keys().size():
		$CanvasLayer/MovementType.add_item(AStar.Solver.movementType.keys()[index], index)
	for index in AStar.Solver.costCalculation.keys().size():
		$CanvasLayer/CostCalculations.add_item(AStar.Solver.costCalculation.keys()[index], index)
	$CanvasLayer/XSize.value = gridSize.x
	$CanvasLayer/YSize.value = gridSize.y
	maze = AStar.Maze.new(gridSize)
	solver = AStar.Solver.new($CanvasLayer/MovementType.selected, $CanvasLayer/CostCalculations.selected)
	cachedPath = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	handle_click()

func _draw() -> void:
	for row in gridSize.y:
		for col in gridSize.x:
			draw_square(col*tileSize, row*tileSize, maze.grid[row*gridSize.x + col]) # Draw all squares
	if (!cachedPath.is_empty()):
		draw_solution(cachedPath)
		cachedPath = []

func draw_square(x: int, y: int, tileType: int) -> void:
	var rect = Rect2(x, y, tileSize, tileSize)
	match tileType:
		0:
			draw_rect(
				rect,
				emptyColor
			)
		1:
			draw_rect(
				rect,
				fillColor
			)
		2:
			draw_rect(
				rect,
				startColor
			)
		3:
			draw_rect(
				rect,
				goalColor
			)
		4:
			draw_rect(
				rect,
				solutionColor
			)
	
	draw_rect( # Draw tile outline
		rect,
		outlineColor,
		false,
		outlineSize
	)

func handle_click() -> void:
	if Input.is_action_pressed("left_click"):
		var gridPos: Vector2 = floor(get_global_mouse_position()/tileSize)
		if (gridPos.x >= 0 && gridPos.y >= 0 && gridPos.x < gridSize.x && gridPos.y < gridSize.y):
			maze.change_tile(
				gridPos.x,
				gridPos.y,
				$CanvasLayer/CellSelector.get_selected_id() + 1
			)
			queue_redraw()
	elif Input.is_action_pressed("right_click"):
		var gridPos: Vector2 = floor(get_global_mouse_position()/tileSize)
		if (gridPos.x >= 0 && gridPos.y >= 0 && gridPos.x < gridSize.x && gridPos.y < gridSize.y):
			maze.change_tile(
				gridPos.x,
				gridPos.y,
				0
			)
			queue_redraw()

func draw_solution(solution: PackedVector2Array) -> void:
	for pos: int in solution.size():
		draw_square(solution[pos].x*tileSize, solution[pos].y*tileSize, 4)

func solve_maze() -> void:
	var startTime: int = Time.get_ticks_msec()
	cachedPath = solver.solve_maze(maze)
	var totalTime: int = Time.get_ticks_msec() - startTime
	$CanvasLayer/SolveTime.text = "Solve time: " + str(totalTime) + "ms"
	$CanvasLayer/PathSize.text = "Path Size: " + str(cachedPath.size()) + " steps"
	queue_redraw()

func set_maze_preset(index: int) -> void:
	$CanvasLayer/MazePresets.selected = -1
	maze.set_maze(PackedInt32Array(presetsDict.values()[index]))
	queue_redraw()

func change_maze_size_to_selected(_val: float) -> void:
	$CanvasLayer/XSize.get_line_edit().release_focus()
	$CanvasLayer/YSize.get_line_edit().release_focus()
	maze.set_size($CanvasLayer/XSize.value, $CanvasLayer/YSize.value)
	gridSize = maze.get_size()
	queue_redraw()

func change_tile_size(val: float) -> void:
	$CanvasLayer/TileSize.get_line_edit().release_focus()
	tileSize = val
	queue_redraw()

func change_movement(index: int) -> void:
	solver.change_movement(index)

func change_cost_calculation(index: int) -> void:
	solver.change_cost_calculation(index)
