extends Control


@onready var click_sound: AudioStreamPlayer = %ClickSound
@export var game_scene: String = "res://Scenes/Terrains/world.tscn"

func _on_start_pressed() -> void:
	print("Start Pressed")
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file(game_scene)


func _on_exit_pressed() -> void:
	print("Exit Pressed")
	click_sound.play()
	await click_sound.finished
	get_tree().quit()
