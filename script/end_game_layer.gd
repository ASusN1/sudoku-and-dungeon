extends CanvasLayer

@onready var stars_sprite: Sprite2D = get_node_or_null("Panel/3Stars0-gameplay2")

const STAR_TEX_3 := preload("res://asset/3_stars-full3.png")
const STAR_TEX_2 := preload("res://asset/3_stars-2.png")
const STAR_TEX_1 := preload("res://asset/3_stars-1.png")
const STAR_TEX_0 := preload("res://asset/3_stars-0.png")

const DIFFICULTY_HINTS := {
	"easy": 10,
	"medium": 5,
	"hard": 3,
}

const NEXT_DIFFICULTY := {
	"easy": "medium",
	"medium": "hard",
	"hard": "hard",
}

var current_stars: int = 1
var current_difficulty: String = "easy"


func _ready() -> void:
	if stars_sprite:
		stars_sprite.hframes = 1
		stars_sprite.vframes = 1
		stars_sprite.frame = 0


func setup_and_show(stars: int, difficulty: String) -> void:
	current_stars = clamp(stars, 0, 3)
	current_difficulty = difficulty
	if stars_sprite:
		stars_sprite.hframes = 1
		stars_sprite.vframes = 1
		stars_sprite.frame = 0
	_update_star_texture(current_stars)
	visible = true


func _update_star_texture(stars: int) -> void:
	if not stars_sprite:
		return

	match stars:
		3:
			stars_sprite.texture = STAR_TEX_3
		2:
			stars_sprite.texture = STAR_TEX_2
		1:
			stars_sprite.texture = STAR_TEX_1
		_:
			stars_sprite.texture = STAR_TEX_0


func _save_progress() -> void:
	var meta_key := "stars_%s" % current_difficulty
	var existing_stars: int = 0
	if get_tree().has_meta(meta_key):
		existing_stars = int(get_tree().get_meta(meta_key))
	get_tree().set_meta(meta_key, max(existing_stars, current_stars))


func _on_play_again_btn_pressed() -> void:
	get_tree().reload_current_scene()


func _on_return_to_menu_btn_pressed() -> void:
	_save_progress()
	get_tree().change_scene_to_file("res://scene/level_selection.tscn")


func _on_next_level_btn_pressed() -> void:
	_save_progress()

	var next_difficulty: String = str(NEXT_DIFFICULTY.get(current_difficulty, "hard"))
	var hints: int = int(DIFFICULTY_HINTS.get(next_difficulty, DIFFICULTY_HINTS["easy"]))
	get_tree().set_meta("selected_difficulty", next_difficulty)
	get_tree().set_meta("selected_hint_count", hints)
	get_tree().change_scene_to_file("res://scene/sudoku_main_gameplay.tscn")
