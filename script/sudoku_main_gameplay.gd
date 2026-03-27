extends Control

const DevMode = preload("res://script/dev_mode.gd")

@onready var grid_container: GridContainer = $CenterContainer/GridContainer
@onready var hint_count_label: Label = get_node_or_null("hint_btn/hint_count")
@onready var pencil_sound: AudioStreamPlayer = get_node_or_null("pencil_sound")
@onready var stars_sprite: Sprite2D = get_node_or_null("3Stars0-gameplay")
@onready var end_game_layer: CanvasLayer = get_node_or_null("End_game")

const STAR_TEX_3 := preload("res://asset/3_stars-full3.png")
const STAR_TEX_2 := preload("res://asset/3_stars-2.png")
const STAR_TEX_1 := preload("res://asset/3_stars-1.png")
const STAR_TEX_0 := preload("res://asset/3_stars-0.png")

const NUMBER_ACTIONS := {
	"One": 1,"Two": 2,"Three": 3,"Four": 4,"Five": 5,
	"Six": 6,"Seven": 7,"Eight": 8,"Nine": 9,
}

var board_data: Array = []
var starting_board: Array = []
var solution_board: Array = []

var selected_cell: Button = null

var difficulty: String = "easy"
var hints_remaining: int = 10
var max_hints: int = 10
var wrong_moves: int = 0
var game_completed: bool = false
@export var dev_mode: bool = true

func _ready() -> void:
	DevMode.set_allow_hints_after_max(dev_mode)

	if get_tree().has_meta("selected_difficulty"):
		difficulty = str(get_tree().get_meta("selected_difficulty"))

	if get_tree().has_meta("selected_hint_count"):
		max_hints = int(get_tree().get_meta("selected_hint_count"))
	else:
		match difficulty:
			"easy":
				max_hints = 10
			"medium":
				max_hints = 5
			"hard":
				max_hints = 3
			_:
				max_hints = 10
	
	hints_remaining = max_hints
	update_hint_label()
	if stars_sprite:
		stars_sprite.hframes = 1
		stars_sprite.vframes = 1
	update_star_texture()

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
	
	solution_board = starting_board.duplicate()

	var positions = range(81)
	positions.shuffle()

	var clues_to_keep = randi_range(20, 26)

	for i in range(clues_to_keep, 81):
		var pos = positions[i]
		starting_board[pos] = 0

	board_data = starting_board.duplicate()

	rebuild_grid()


func rebuild_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for i in range(81):
		var btn = Button.new()
		
		if starting_board[i] != 0:
			btn.text = str(starting_board[i])
			btn.disabled = true
			btn.modulate = Color.BLACK
		else:
			btn.text = ""
			btn.modulate = Color.WHITE
		
		btn.custom_minimum_size = Vector2(50, 50)
		btn.pressed.connect(_on_cell_pressed.bind(btn))
		
		grid_container.add_child(btn)


func _on_cell_pressed(btn: Button) -> void:
	if selected_cell != null and is_instance_valid(selected_cell):
		if starting_board[selected_cell.get_index()] == 0:
			selected_cell.modulate = Color.WHITE
		else:
			selected_cell.modulate = Color(0.85, 0.85, 0.85, 1)

	selected_cell = btn
	selected_cell.modulate = Color(0.4, 1.0, 0.4, 1)


func _process(_delta: float) -> void:
	for action in NUMBER_ACTIONS:
		if Input.is_action_just_pressed(action):
			place_number(NUMBER_ACTIONS[action])


func place_number(number: int) -> void:
	if selected_cell == null or not is_instance_valid(selected_cell):
		return
	
	var idx = selected_cell.get_index()

	if starting_board[idx] != 0:
		return
	
	if is_valid_move(idx, number):
		selected_cell.text = str(number)
		board_data[idx] = number
		selected_cell.modulate = Color.WHITE
		if pencil_sound:
			pencil_sound.stop()
			pencil_sound.play()
		check_game_completed()
	else:
		wrong_moves += 1
		update_star_texture()
		selected_cell.text = ""
		board_data[idx] = 0
		selected_cell.modulate = Color(1.0, 0.4, 0.4, 1)
		await get_tree().create_timer(0.4).timeout
		if is_instance_valid(selected_cell):
			selected_cell.modulate = Color.WHITE


func is_valid_move(cell_index: int, number: int) -> bool:
	var row = cell_index / 9
	var col = cell_index % 9
	
	for i in range(9):
		var idx = row * 9 + i
		if idx != cell_index and board_data[idx] == number:
			return false

	for i in range(9):
		var idx = i * 9 + col
		if idx != cell_index and board_data[idx] == number:
			return false

	var box_row = (row / 3) * 3
	var box_col = (col / 3) * 3
	
	for i in range(3):
		for j in range(3):
			var idx = (box_row + i) * 9 + (box_col + j)
			if idx != cell_index and board_data[idx] == number:
				return false
	
	return true


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
	

func _on_hint_btn_pressed() -> void:
	if not DevMode.can_use_hint(hints_remaining):
		print("No hints remaining!")
		return

	var empty_cells: Array = []
	for i in range(81):
		if board_data[i] == 0 and starting_board[i] == 0:
			empty_cells.append(i)

	if empty_cells.is_empty():
		print("No empty cells to solve!")
		return

	var random_index = empty_cells[randi() % empty_cells.size()]

	var solution_value = solution_board[random_index]

	board_data[random_index] = solution_value

	var cells = grid_container.get_children()
	if random_index < cells.size():
		var btn = cells[random_index]
		btn.text = str(solution_value)
		btn.modulate = Color(0.7, 1.0, 0.7, 1)

	hints_remaining = DevMode.consume_hint(hints_remaining)
	update_hint_label()
	update_star_texture()
	check_game_completed()


func update_hint_label() -> void:
	if hint_count_label:
		hint_count_label.text = "Hints: %d/%d" % [hints_remaining, max_hints]
	else:
		push_warning("hint_btn/hint_count label not found in scene.")


func update_star_texture() -> void:
	if not stars_sprite:
		return

	var stars := get_current_stars()

	match stars:
		3:
			stars_sprite.texture = STAR_TEX_3
		2:
			stars_sprite.texture = STAR_TEX_2
		1:
			stars_sprite.texture = STAR_TEX_1
		_:
			stars_sprite.texture = STAR_TEX_0


func get_current_stars() -> int:
	var hints_used = max_hints - hints_remaining
	var stars := 3
	if hints_used > 3:
		stars -= 1
	if wrong_moves >= 5:
		stars -= 1
	return clamp(stars, 1, 3)


func check_game_completed() -> void:
	if game_completed:
		return

	for value in board_data:
		if int(value) == 0:
			return

	game_completed = true
	if end_game_layer and end_game_layer.has_method("setup_and_show"):
		end_game_layer.call("setup_and_show", get_current_stars(), difficulty)


func set_allow_hints_after_max_for_testing(enabled: bool) -> void:
	dev_mode = enabled
	DevMode.set_allow_hints_after_max(enabled)
