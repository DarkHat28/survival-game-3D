extends CharacterBody3D
class_name Enemy

@export var roaming_speed :float = 200
@export var chasing_speed: float = 400.0
@export var gravity: float = 12.0
@export var attack_range: float = 1.5
@export var chase_range: float = 20.0
@export var max_health :float = 100
var health := max_health
@export var damage: = 10


var scream_time_range = [25,50]
var movement_speed = roaming_speed

var chasing := false
var attacking := false
var walking := true
var screaming :=false

var prev_pos: Vector3 = Vector3.ZERO
var target_position: Vector3

@onready var anim: AnimationPlayer = $Zombie/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	await get_tree().process_frame
	set_random_target()
	$scream_timer.start(randf_range(scream_time_range[0],scream_time_range[1]))

func _physics_process(delta: float) -> void:
	if(health<=0):
		anim.speed_scale = 1.5
		if(anim.current_animation!= "zombie_dying"):
			anim.play("zombie_dying")
			$die_timer.start(3.333/anim.speed_scale)
			
	if(anim.current_animation == "zombie_attack"):
		if(anim.current_animation_position>1 and anim.current_animation_position<1.5):
			$hitbox/CollisionShape3D.disabled = false
		else:
			$hitbox/CollisionShape3D.disabled=true
	
	if(attacking):
		anim.speed_scale = 2
	elif(screaming):
		anim.speed_scale = 0.5
	else:
		anim.speed_scale = 1
	if anim.current_animation == "zombie_attack":
		return
	if(anim.current_animation == "zombie_scream"):
		return
	
	var dist := global_position.distance_to(Global.player_pos)
	rotation_degrees.x = 0
	rotation_degrees.z = 0
	movement_speed = roaming_speed if walking else chasing_speed
	if dist <= attack_range:
		attacking = true
		chasing = false
		walking = false
		navigation_agent.set_target_position(global_position)
		velocity.x = 0
		velocity.z = 0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		_anim(dist)
		return

	attacking = false

	if navigation_agent.is_navigation_finished() and dist > chase_range:
		set_random_target()

	if dist < chase_range and dist > attack_range:
		var offset := Global.player_pos.direction_to(global_position).normalized()*0.2
		navigation_agent.set_target_position(Global.player_pos + offset)

	if navigation_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	else:
		var next_pos: Vector3 = navigation_agent.get_next_path_position()
		var dir: Vector3 = (next_pos - global_position).normalized()
		var flat := Vector3(dir.x, 0.0, dir.z)
		velocity.x = flat.x * movement_speed  *delta  
		velocity.z = flat.z * movement_speed *delta  

	var next = navigation_agent.get_next_path_position()
	var direct = (next - global_position).normalized()
	direct.y = 0.0
	if (next - global_position).normalized().length()>=0.01:
		if(is_on_floor()):
			look_at(global_position + direct, Vector3.UP, true)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	_anim(dist)

func set_random_target() -> void:
	var nav_map := navigation_agent.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(nav_map) <= 0:
		return
	var random_point := NavigationServer3D.map_get_random_point(nav_map, 1, 1)
	var closest_point := NavigationServer3D.map_get_closest_point(nav_map, random_point)
	target_position = closest_point
	navigation_agent.set_target_position(target_position)

func _on_timer_timeout() -> void:
	var dist := global_position.distance_to(Global.player_pos)
	if dist < chase_range and dist > attack_range:
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) <= 0:
			return
		var offset := Global.player_pos.direction_to(global_position).normalized() * attack_range
		navigation_agent.set_target_position(Global.player_pos + offset)
		return
	elif dist <= attack_range:
		navigation_agent.set_target_position(global_position)
		return
	if global_position.distance_to(prev_pos) <= 0.001:
		set_random_target()
	prev_pos = global_position

func _anim(dist: float) -> void:
	if dist < attack_range:
		attacking = true
		chasing = false
		walking = false
		if anim.current_animation != "zombie_attack":
			anim.play("zombie_attack")
		return

	if dist < chase_range:
		chasing = true
		attacking = false
		walking = false
		if anim.current_animation != "zombie_run":
			anim.play("zombie_run")
	else:
		chasing = false
		attacking = false
		walking = true
		if anim.current_animation != "zombie_walk":
			anim.play("zombie_walk")


func _on_scream_timer_timeout():
	if(walking):
		screaming = true
		anim.play("zombie_scream")
		$scream_sound.play()
	$Timer.start(randf_range(scream_time_range[0],scream_time_range[1]))


func _on_die_timer_timeout():
	queue_free()
	Global.killed+=1


func _on_hitbox_body_entered(body):
	if body is mainplayer:
		body.health -= damage
		Global.emit_signal("change_health",body.health)
