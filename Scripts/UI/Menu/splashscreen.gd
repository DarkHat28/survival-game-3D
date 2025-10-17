extends Control



func _on_splash_screen_animation_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file("uid://bf0fk3pbqkh8v") # "res://Scenes/UI/main_menu.tscn"
