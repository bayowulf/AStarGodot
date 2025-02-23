extends Node2D

@export_category("Maze")
@export var gridSize: Vector2 = Vector2(10, 10)
@export var tileSize: int = 16

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maze = AStar.Maze.new(gridSize)
	solver = AStar.Solver.new(AStar.Solver.movementType.CARDINAL)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	handle_click()

func _draw() -> void:
	for row in gridSize.y:
		for col in gridSize.x:
			draw_square(col*tileSize, row*tileSize, maze.grid[row*gridSize.x + col]) # Draw all squares
	if (solver.has_cached_solution()):
		draw_solution(solver.get_cached_solution())
		solver.clear_cache()

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
			if (maze.get_tile_type(gridPos.x, gridPos.y) == 0):
				maze.change_tile(
					gridPos.x,
					gridPos.y,
					1
				)
				queue_redraw()
	elif Input.is_action_pressed("right_click"):
		var gridPos: Vector2 = floor(get_global_mouse_position()/tileSize)
		if (gridPos.x >= 0 && gridPos.y >= 0 && gridPos.x < gridSize.x && gridPos.y < gridSize.y):
			if (maze.get_tile_type(gridPos.x, gridPos.y) == 1):
				maze.change_tile(
					gridPos.x,
					gridPos.y,
					0
				)
				queue_redraw()

func draw_solution(solution: PackedVector2Array) -> void:
	for pos: Vector2 in solution:
		draw_square(pos.x*tileSize, pos.y*tileSize, 4)

func solve_maze() -> void:
	solver.solve_maze(maze)
	$CanvasLayer/SolveTime.text = "Solve time: " + str(solver.get_solve_time()) + "ms"
	queue_redraw()
