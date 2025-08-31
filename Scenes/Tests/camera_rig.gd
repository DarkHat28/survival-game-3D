# TPSCamera.gd
# Attach to CameraRig (Node3D), child of your Player (CharacterBody3D)
class_name TPSCamera extends Node3D
@export_group("Nodes")
@export var player: Node3D
@export var horizontal_pivot: Node3D
@export var vertical_pivot: Node3D
@export var cam: Camera3D

# Optional offsets: if present in the scene, assign them, otherwise the script will fallback to pivot usage
@export var root_offset: Node3D
@export var leaf_offset: Node3D

@export_group("TPS Settings")
# Camera behavior
@export_range(0.001, 10.0, 0.001) var mouse_sensitivity := 0.35
@export var invert_y := false
@export_range(-89.0, 0.0) var pitch_min_deg := -80.0
@export_range(0.0, 89.0) var pitch_max_deg := 80.0

# Smoothing
@export var rotation_smooth_speed := 12.0    # higher = snappier
@export var position_smooth_speed := 12.0

# Distances / FOV
@export var normal_distance := 3.2
@export var ads_distance := 0.9
@export var normal_fov := 70.0
@export var ads_fov := 50.0
@export var ads_transition_speed := 10.0

# Over-the-shoulder offsets
@export var shoulder_offset_x := 0.6   # lateral offset from center (meters)
@export var shoulder_offset_y := 0.15  # small vertical offset
@export var shoulder_raise := 0.2      # small forward raise if needed

# Head height (from player origin) used as camera trace origin
@export var head_height := 1.6

# Collision margin so camera doesn't clip into hit geometry
@export var collision_margin := 0.15
@export var collision_mask := 1    # customize: which physics layers the camera collides with


@export_group("Movement")
@export var min_limit_x: float = 5
@export var max_limit_x: float = 0.2
#@export var horizontal_acceleration: float= 2.0
#@export var vertical_acceleration: float = 1.0
@export var mouse_acceleration := 0.005

#@export_group("Camera Speed")
#@export var look_speed: float = 0.07
#@export var base_speed: float = 2.0
#@onready var camera_pivot: Node3D = $CameraPivot
#@onready var camera: Camera3D = $CameraPivot/Camera

var mouse_captured: bool = false
var look_rotation: Vector2 = Vector2()



var _target_yaw := 0.0
var _target_pitch := 0.0
var _cur_yaw := 0.0
var _cur_pitch := 0.0

var _current_distance := 0.0
var _target_distance := 0.0

var _target_fov := 0.0

var _shoulder_side := 1          # 1 = right, -1 = left
var _target_offset_x := 0.0
var _current_offset_x := 0.0

func _ready():
	# resolve nodes
	if player == null:
		#player = get_parent()
		push_error("TPSCamera: player_path not set and parent not found.")
		return
	if horizontal_pivot == null or vertical_pivot == null or cam == null:
		push_error("TPSCamera: Please assign horizontal_pivot_path, vertical_pivot_path and camera_node_path.")
		return

	# start angles from current transforms
	_cur_yaw = horizontal_pivot.rotation.y
	_cur_pitch = vertical_pivot.rotation.x
	_target_yaw = _cur_yaw
	_target_pitch = _cur_pitch

	_target_distance = normal_distance
	_current_distance = _target_distance
	_target_fov = normal_fov
	cam.fov = normal_fov

	_target_offset_x = _shoulder_side * shoulder_offset_x
	_current_offset_x = _target_offset_x

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var rel = event.relative
		var dx = -rel.x * (mouse_sensitivity * 0.01)
		var dy = -rel.y * (mouse_sensitivity * 0.01)
		_target_yaw += dx
		if invert_y:
			_target_pitch += -dy
		else:
			_target_pitch += dy
		# clamp pitch in degrees -> convert to radians for storage
		_target_pitch = clamp(rad_to_deg(_target_pitch), pitch_min_deg, pitch_max_deg)
		_target_pitch = rad_to_deg(_target_pitch)

func _input(event: InputEvent) -> void:
	# aim (ADS) handled in _process to allow smoothing
	# switch shoulder:
	if event.is_action_pressed("switch_shoulder"):
		_switch_shoulder()

	# toggle mouse capture (Escape commonly toggles)
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acceleration)
	#grab_mouse()

func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y -= v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x) # Clamping Vertical Rotation

#func grab_mouse() -> void:
	#if Input.is_action_just_pressed("toggle_mouse_capture"):
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # Release mouse if mouse mode is captured
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Recapture mouse when clicking in window



func _switch_shoulder():
	_shoulder_side *= -1
	_target_offset_x = _shoulder_side * shoulder_offset_x

func _process(delta: float) -> void:
	_update_ads(delta)
	_update_rotation(delta)

func _physics_process(delta: float) -> void:
	_update_position_and_collision(delta)

# --- ADS and distance/FOV transitions
func _update_ads(delta: float) -> void:
	var aim_pressed := Input.is_action_pressed("aim")
	if aim_pressed:
		_target_distance = ads_distance
		_target_fov = ads_fov
		# bring camera nearer to center during ADS (reduce shoulder offset)
		_target_offset_x = lerp(_target_offset_x, 0.14 * _shoulder_side, delta * 6.0)
	else:
		_target_distance = normal_distance
		_target_fov = normal_fov
		_target_offset_x = _shoulder_side * shoulder_offset_x

	# smooth update for distance & FOV
	_current_distance = lerp(_current_distance, _target_distance, clamp(ads_transition_speed * delta, 0.0, 1.0))
	cam.fov = lerp(cam.fov, _target_fov, clamp(ads_transition_speed * delta, 0.0, 1.0))

	# smooth shoulder offset separately
	_current_offset_x = lerp(_current_offset_x, _target_offset_x, clamp(position_smooth_speed * delta, 0.0, 1.0))

# --- Apply rotation to pivots with smoothing
func _update_rotation(delta: float) -> void:
	# smooth angles using lerp_angle
	_cur_yaw = lerp_angle(_cur_yaw, _target_yaw, clamp(rotation_smooth_speed * delta, 0.0, 1.0))
	_cur_pitch = lerp_angle(_cur_pitch, _target_pitch, clamp(rotation_smooth_speed * delta, 0.0, 1.0))

	horizontal_pivot.rotation = Vector3(0.0, _cur_yaw, 0.0)
	vertical_pivot.rotation = Vector3(_cur_pitch, 0.0, 0.0)

# --- Position target & collision avoidance
func _update_position_and_collision(delta: float) -> void:
	# Origin for camera trace (player head)
	var from = player.global_transform.origin + Vector3(0, head_height, 0)

	# Determine the offset parent
	var offset_parent: Node3D = null
	if leaf_offset != null:
		offset_parent = leaf_offset
	elif root_offset != null:
		offset_parent = root_offset
	else:
		offset_parent = vertical_pivot

	# Desired local camera position
	var desired_local = Vector3(_current_offset_x, shoulder_offset_y + shoulder_raise, -_current_distance)

	# Convert to global position
	var desired_global = offset_parent.global_transform.origin + offset_parent.global_transform.basis * desired_local

	# Raycast from head to desired camera position
	var space = get_world_3d().direct_space_state
	var exclude = [player]
	var query = PhysicsRayQueryParameters3D.create(from, desired_global)
	query.exclude = exclude
	query.collision_mask = collision_mask

	var hit = space.intersect_ray(query)

	var final_pos: Vector3
	if hit.is_empty():
		final_pos = desired_global
	else:
		final_pos = hit.position + hit.normal * collision_margin

	# Smooth camera position
	var cur_pos = cam.global_transform.origin
	var new_pos = cur_pos.lerp(final_pos, clamp(position_smooth_speed * delta, 0.0, 1.0))

	# Apply transform to camera
	var look_at_target = from
	var cam_transform = cam.global_transform
	cam_transform.origin = new_pos
	cam.global_transform = cam_transform
	cam.look_at(look_at_target, Vector3.UP)
