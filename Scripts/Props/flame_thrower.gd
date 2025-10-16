extends Node3D


@onready var gun_flame: GPUParticles3D = %GunFlame
@onready var shape_cast: ShapeCast3D = %ShapeCast
@onready var flame_progress_bar: ProgressBar = %FlameProgressBar

#@onready var player: Player = Global.player

var firing: bool = false
var firing_cost: float = 5.0


func _unhandled_input(_event):
	if Input.is_action_pressed("fire"):
		firing = true
	else:
		firing = false
		gun_flame.local_coords = false
		

func _process(delta):
	if firing and Global.ammo > 0:
		gun_flame.emitting = true
		#gun_flame.visible = true
		shape_cast.enabled = true
		Global.ammo -= firing_cost * delta
	else:
		gun_flame.emitting = false
		#gun_flame.visible = false
		shape_cast.enabled = false
	
	flame_progress_bar.value = Global.ammo
