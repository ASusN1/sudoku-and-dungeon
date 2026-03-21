extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed ()-> void:
	get_tree().change_scene_to_file("res://scene/level_selection.tscn")


func _on_setting_pressed() -> void:
	pass 
	#Repalce this with a like seeting sceence , option to select musis, how to play tthe game. 



func _on_quit_pressed() -> void:
	get_tree().quit()
