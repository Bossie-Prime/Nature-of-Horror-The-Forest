extends Node2D

func _ready() -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options_pressed() -> void:
	var settings_layer = get_tree().get_first_node_in_group("settings_layer")
	if settings_layer:
		settings_layer.open_settings()

func _on_quit_pressed() -> void:
	get_tree().quit()
