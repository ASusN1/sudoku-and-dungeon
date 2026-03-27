extends Node2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass



func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")



func _on_music_on_of_pressed() -> void:
	var music_player = _get_background_music_player()
	if music_player == null:
		return

	music_player.stream_paused = not music_player.stream_paused
	if not music_player.stream_paused and not music_player.playing:
		music_player.play()


func _get_background_music_player() -> AudioStreamPlayer:
	return get_node_or_null("/root/BackgroundMusic/background_music") as AudioStreamPlayer
