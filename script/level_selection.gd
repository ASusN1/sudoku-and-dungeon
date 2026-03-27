extends Node2D

const DIFFICULTY_HINTS := {
	"easy": 10,
	"medium": 5,
	"hard": 3,
}

const STAR_TEX_3 := preload("res://asset/3_stars-full3.png")
const STAR_TEX_2 := preload("res://asset/3_stars-2.png")
const STAR_TEX_1 := preload("res://asset/3_stars-1.png")
const STAR_TEX_0 := preload("res://asset/3_stars-0.png")

@onready var easy_label: Label = $level_maneger/ColorRect/Easy
@onready var medium_label: Label = $level_maneger/ColorRect/Medium
@onready var hard_label: Label = $level_maneger/ColorRect/Hard
@onready var easy_star: TextureRect = $level_maneger/ColorRect/star
@onready var medium_star: TextureRect = $level_maneger/ColorRect/star2
@onready var hard_star: TextureRect = $level_maneger/ColorRect/star3

func _ready() -> void:
	easy_label.text = "EASY\nHints: %d" % DIFFICULTY_HINTS["easy"]
	medium_label.text = "MEDIUM\nHints: %d" % DIFFICULTY_HINTS["medium"]
	hard_label.text = "HARD\nHints: %d" % DIFFICULTY_HINTS["hard"]
	_update_star()


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

func _update_star() -> void:
	_apply_star_texture(easy_star, _get_saved_stars("easy"))
	_apply_star_texture(medium_star, _get_saved_stars("medium"))
	_apply_star_texture(hard_star, _get_saved_stars("hard"))


func _get_saved_stars(selected_difficulty: String) -> int:
	var meta_key := "stars_%s" % selected_difficulty
	if not get_tree().has_meta(meta_key):
		return 0
	return clamp(int(get_tree().get_meta(meta_key)), 0, 3)


func _apply_star_texture(target: TextureRect, stars: int) -> void:
	if not target:
		return

	match stars:
		3:
			target.texture = STAR_TEX_3
		2:
			target.texture = STAR_TEX_2
		1:
			target.texture = STAR_TEX_1
		_:
			target.texture = STAR_TEX_0
