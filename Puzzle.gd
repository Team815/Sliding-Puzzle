extends Node2D


var grid = []
var dimensions = Vector2(4, 4)
var puzzle_image_size = Vector2(256, 256)
var puzzle_piece_size = puzzle_image_size / dimensions
var empty_space = Vector2()
var mixup_moves = 2#dimensions.x * dimensions.y * 2
var random_puzzle_piece_previous


func _ready():
	randomize()
	var puzzle_piece_res = preload("res://PuzzlePiece.tscn")
	for i in range (dimensions.x):
		grid.append([])
		for j in range (dimensions.y):
			var puzzle_piece = puzzle_piece_res.instance()
			add_child(puzzle_piece)
			puzzle_piece.get_node("Tween").connect("tween_all_completed", self, "_on_Tween_tween_all_completed", [puzzle_piece])
			puzzle_piece.position = _get_piece_position(Vector2(i, j))
			puzzle_piece.region_enabled = true
			puzzle_piece.region_rect = Rect2(Vector2(i, j) * puzzle_piece_size, puzzle_piece_size)
			puzzle_piece.location_correct = Vector2(i, j)
			grid[i].append(puzzle_piece)
	grid[0][0].queue_free()
	_move_random_piece()


func _input(event):
	if mixup_moves == 0:
		_input_after_mixup(event)


func _input_after_mixup(event):
	if event.is_action_pressed("ui_left") and empty_space.x < dimensions.x - 1:
		var puzzle_piece_moving = grid[empty_space.x + 1][empty_space.y]
		grid[empty_space.x][empty_space.y] = puzzle_piece_moving
		puzzle_piece_moving.move_to(_get_piece_position(empty_space))
		empty_space.x += 1
	elif event.is_action_pressed("ui_right") and empty_space.x > 0:
		var puzzle_piece_moving = grid[empty_space.x - 1][empty_space.y]
		grid[empty_space.x][empty_space.y] = puzzle_piece_moving
		puzzle_piece_moving.move_to(_get_piece_position(empty_space))
		empty_space.x -= 1
	elif event.is_action_pressed("ui_up") and empty_space.y < dimensions.y - 1:
		var puzzle_piece_moving = grid[empty_space.x][empty_space.y + 1]
		grid[empty_space.x][empty_space.y] = puzzle_piece_moving
		puzzle_piece_moving.move_to(_get_piece_position(empty_space))
		empty_space.y += 1
	elif event.is_action_pressed("ui_down") and empty_space.y > 0:
		var puzzle_piece_moving = grid[empty_space.x][empty_space.y - 1]
		grid[empty_space.x][empty_space.y] = puzzle_piece_moving
		puzzle_piece_moving.move_to(_get_piece_position(empty_space))
		empty_space.y -= 1

func _on_Tween_tween_all_completed(puzzle_piece):
	if mixup_moves > 0:
		_move_random_piece()
	var win = true
	for i in grid.size():
		for j in grid.size():
			if Vector2(i, j) != empty_space and grid[i][j].location_correct != Vector2(i, j):
				win = false
	if win:
		print("Winner!")


func _move_random_piece():
	var random_location = Vector2(-1, -1)
	while not _is_valid_location(random_location):
		var random = randi() % 4
		match random:
			0:
				random_location = empty_space + Vector2(0, 1)
			1:
				random_location = empty_space + Vector2(1, 0)
			2:
				random_location = empty_space + Vector2(0, -1)
			3:
				random_location = empty_space + Vector2(-1, 0)
	var random_puzzle_piece = grid[random_location.x][random_location.y]
	grid[empty_space.x][empty_space.y] = random_puzzle_piece
	random_puzzle_piece.move_to(_get_piece_position(empty_space))
	empty_space = random_location
	random_puzzle_piece_previous = random_puzzle_piece
	mixup_moves -= 1
	


func _is_valid_location(location: Vector2):
	return \
	location.x >= 0 and \
	location.y >= 0 and \
	location.x < dimensions.x and \
	location.y < dimensions.y and \
	grid[location.x][location.y] != random_puzzle_piece_previous


func _get_piece_position(location):
	return location * puzzle_piece_size
