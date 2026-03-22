extends Node2D

const DIFFICULTY_HINTS := {
	"easy": 10,
	"medium": 5,
	"hard": 3,
}

@onready var easy_label: Label = $level_maneger/ColorRect/Easy
@onready var medium_label: Label = $level_maneger/ColorRect/Medium
@onready var hard_label: Label = $level_maneger/ColorRect/Hard

func _ready() -> void:
	easy_label.text = "EASY\nHints: %d" % DIFFICULTY_HINTS["easy"]
	medium_label.text = "MEDIUM\nHints: %d" % DIFFICULTY_HINTS["medium"]
	hard_label.text = "HARD\nHints: %d" % DIFFICULTY_HINTS["hard"]


func _process(delta: float) -> void:
	pass


func _start_game(selected_difficulty: String) -> void:
	var hints: int = int(DIFFICULTY_HINTS.get(selected_difficulty, DIFFICULTY_HINTS["easy"]))
	get_tree().set_meta("selected_difficulty", selected_difficulty)
	get_tree().set_meta("selected_hint_count", hints)
	get_tree().change_scene_to_file("res://scene/sudoku_main_gameplay.tscn")


func _on_easy_btn_pressed() -> void:
	_start_game("easy")


func _on_medium_btn_pressed() -> void:
	_start_game("medium")


func _on_hard_btn_pressed() -> void:
	_start_game("hard")


func _on_return_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
