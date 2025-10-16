extends CharacterBody3D

@export var movement_speed: float = 100.0
@export var door_open_time: float = 1

var prev_pos:Vector3 = Vector3.ZERO
var range_dist :float = 30

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var target_position: Vector3

func _ready():
	await get_tree().process_frame
	set_random_target()

func _physics_process(delta):
	rotation_degrees.x=0
	rotation_degrees.z=0

	if navigation_agent.is_navigation_finished():
		set_random_target()

	var next_pos = navigation_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity = direction * movement_speed * delta
	if velocity.length() > 0.01:
		look_at(global_position - velocity.normalized(), Vector3.UP)
	move_and_slide()

func set_random_target():
	var nav_map = navigation_agent.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(nav_map) <= 0:
		return
	
	var random_point = NavigationServer3D.map_get_random_point(nav_map,1,1)
	var closest_point = NavigationServer3D.map_get_closest_point(nav_map, random_point)
	target_position = closest_point
	navigation_agent.set_target_position(target_position)



func _on_timer_timeout():
	if(global_position.distance_to(Global.player_pos)<range_dist):
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) <= 0:
			return
		navigation_agent.set_target_position(Global.player_pos)
		print(1)
		return
	if(global_position.distance_to(prev_pos)<=0.001):
		set_random_target()
	prev_pos=global_position
