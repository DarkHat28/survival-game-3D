extends Node3D


@onready var gun_flame: GPUParticles3D = %GunFlame
@onready var shape_cast: ShapeCast3D = %ShapeCast
@onready var flame_progress_bar: ProgressBar = %FlameProgressBar

#@onready var player: Player = Global.player

var firing: bool = false
@export var firing_cost: float = 2.0
@export var dps:float = 40


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
	if(%ShapeCast.is_colliding()):
		for i in %ShapeCast.get_collision_count():
			var col :Node3D= %ShapeCast.get_collider(i) as Node3D
			if col:
				if col is Enemy:
					col.health -= dps * delta


func _physics_process(_delta: float) -> void:
	gun_flame.global_position = %FlamePosition.global_position
	gun_flame.global_rotation = %FlamePosition.global_rotation
