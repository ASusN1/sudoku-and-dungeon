extends Control

@onready var grid_container: GridContainer = $CenterContainer/GridContainer

var board_data: Array = []
var starting_board: Array = []

var selected_cell: Button = null

func _ready() -> void:
	random_generate_sudoku()

func random_generate_sudoku() -> void:
	starting_board = []
	starting_board.resize(81)
	starting_board.fill(0)
	
	var numbers = [1,2,3,4,5,6,7,8,9]
	
	for block in range(9):
		numbers.shuffle()
		var row_offset = (block / 3) * 3
		var col_offset = (block % 3) * 3
		var idx = 0
		for i in range(3):
			for j in range(3):
				var r = row_offset + i
				var c = col_offset + j
				var pos = r * 9 + c
				starting_board[pos] = numbers[idx]
				idx += 1
	
	# Randomly remove most numbers to create a puzzle 
	var positions = range(81)
	positions.shuffle()
	
	# How many clues to keep (17–25 = easy puzzle, 30–35 = medium, smt like that) 
	var clues_to_keep = randi_range(20, 26)
	
	for i in range(clues_to_keep, 81):
		var pos = positions[i]
		starting_board[pos] = 0
	
	# Sync playing board with starting board
	board_data = starting_board.duplicate()
	
	# Build the visual grid
	rebuild_grid()


func rebuild_grid() -> void:
	# Clear old buttons
	for child in grid_container.get_children():
		child.queue_free()
	
	for i in range(81):
		var btn = Button.new()
		
		if starting_board[i] != 0:
			btn.text = str(starting_board[i])
			btn.disabled = true
			btn.modulate = Color.BLACK # light gray for given numbers
		else:
			btn.text = ""
			btn.modulate = Color.WHITE
		
		btn.custom_minimum_size = Vector2(50, 50)
		btn.pressed.connect(_on_cell_pressed.bind(btn))
		
		grid_container.add_child(btn)


func _on_cell_pressed(btn: Button) -> void:
	# Reset previous selection
	if selected_cell != null and is_instance_valid(selected_cell):
		if starting_board[selected_cell.get_index()] == 0:
			selected_cell.modulate = Color.WHITE
		else:
			selected_cell.modulate = Color(0.85, 0.85, 0.85, 1)
	
	# Select new cell
	selected_cell = btn
	selected_cell.modulate = Color(0.4, 1.0, 0.4, 1)  # light green


func _process(_delta: float) -> void:
	var input_map = {
		"One": 1, "Two": 2, "Three": 3, "Four": 4,
		"Five": 5, "Six": 6, "Seven": 7, "Eight": 8, "Nine": 9
	}
	
	for action in input_map:
		if Input.is_action_just_pressed(action):
			place_number(input_map[action])


func place_number(number: int) -> void:
	if selected_cell == null or not is_instance_valid(selected_cell):
		return
	
	var idx = selected_cell.get_index()
	
	# Can't change given numbers
	if starting_board[idx] != 0:
		return
	
	if is_valid_move(idx, number):
		selected_cell.text = str(number)
		board_data[idx] = number
		selected_cell.modulate = Color.WHITE
	else:
		selected_cell.text = ""
		board_data[idx] = 0
		selected_cell.modulate = Color(1.0, 0.4, 0.4, 1) 
		await get_tree().create_timer(0.4).timeout
		if is_instance_valid(selected_cell):
			selected_cell.modulate = Color.WHITE


func is_valid_move(cell_index: int, number: int) -> bool:
	var row = cell_index / 9
	var col = cell_index % 9
	
	# Check row
	for i in range(9):
		var idx = row * 9 + i
		if idx != cell_index and board_data[idx] == number:
			return false
	
	# Check column
	for i in range(9):
		var idx = i * 9 + col
		if idx != cell_index and board_data[idx] == number:
			return false
	
	# Check 3×3 box
	var box_row = (row / 3) * 3
	var box_col = (col / 3) * 3
	
	for i in range(3):
		for j in range(3):
			var idx = (box_row + i) * 9 + (box_col + j)
			if idx != cell_index and board_data[idx] == number:
				return false
	
	return true


# Optional: click outside to deselect
func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_cell != null and is_instance_valid(selected_cell):
			if starting_board[selected_cell.get_index()] == 0:
				selected_cell.modulate = Color.WHITE
			else:
				selected_cell.modulate = Color(0.85, 0.85, 0.85, 1)
		selected_cell = null




func _on_return_to_stage_selection_pressed():
	get_tree().change_scene_to_file("res://scene/level_selection.tscn")
