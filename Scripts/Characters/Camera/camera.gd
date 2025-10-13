class_name PlayerCamera
extends Node3D

#region Variables
@export_category("Player Reference")
@export var player: CharacterBody3D

@export_category("Camera View")
@export var can_switch: bool
enum CameraMode { F_P_S,T_P_S }
@export var camera_mode: CameraMode = CameraMode.F_P_S


@onready var spring_arm: SpringArm3D = %SpringArm
@onready var fps_camera: Camera3D = %FPSCamera
@onready var tps_camera: Camera3D = %TPSCamera
@onready var active_camera: Camera3D

## FlameThrowerSkins
const FLAME_THROWER_BLUE = preload("uid://bt38bt2epaoct") # "res://Scenes/Weapons/flame_thrower_blue.tscn"
const FLAME_THROWER_GOLDEN = preload("uid://naeeiv52mtr0") # "res://Scenes/Weapons/flame_thrower_golden.tscn"
const FLAME_THROWER_GREY = preload("uid://cesc7xsio46t8") # "res://Scenes/Weapons/flame_thrower_grey.tscn"
const FLAME_THROWER_PINK = preload("uid://c1q5a2i3bd2lc") # "res://Scenes/Weapons/flame_thrower_pink.tscn"



@export var current_flame_thrower: PackedScene = FLAME_THROWER_BLUE


@export_group("Camera Rotation")
# Sensitivity settings
@export var mouse_sensitivity: float = 0.002 # Usually very small number ex: 0.002
@export_range(0.0, 90.0, 1.0) var max_vertical_angle: float = 57.0 # Upside limit
@export_range(0.0, 90.0, 1.0) var min_vertical_angle: float = 67.0 # Downside limit
## Vertical Camera Rotation Limits in PUBG Mobile: Approximately +60 to +85 degrees
## The total vertical rotation range is about 120° to 170°, depending on the situation and the camera mode (e.g., TPP vs. FPP).
@export_group("Spring Arm Settings")
@export var min_spring_length: float = 1.5
@export var max_spring_length: float = 4.0
@export_range(0.0, 1.0, 0.1) var spring_arm_length_step: float = 0.2

# Script Inbuilt variables
var mouse_rotation: Vector2 = Vector2.ZERO
var vertical_rotation: float = 0.0
var can_player_rotate: bool = true
#endregion

func _ready() -> void:
	# Make sure mouse is captured
	_camera_mode()
	spring_arm.spring_length = 2.5
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Instantiate Flame Thrower
	var flame_thrower: Node3D = current_flame_thrower.instantiate()
	%FlameThrowerPosition.add_child(flame_thrower)

func _input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_rotation = event.relative * mouse_sensitivity
		rotate_camera()
	_grab_mouse()
	_switch_camera()
	update_spring_arm()

func _process(_delta):
	# Smoothly rotate the camera
	if mouse_rotation.length() > 0:
		rotate_camera()
		mouse_rotation = Vector2.ZERO

func _camera_mode() -> void:
	match camera_mode:
		CameraMode.F_P_S:
			active_camera = fps_camera
		CameraMode.T_P_S:
			active_camera = tps_camera


func rotate_camera():
	# Rotate the player horizontally
	player.rotate_y(-mouse_rotation.x)
	# Update vertical rotation and clamp it
	vertical_rotation = clamp(vertical_rotation - mouse_rotation.y, deg_to_rad(-min_vertical_angle), deg_to_rad(max_vertical_angle))
	rotation.x = vertical_rotation # Apply the vertical rotation to the camera's X-axis (pitch)

func update_spring_arm() -> void:
	if active_camera == tps_camera:
		if Input.is_action_pressed("wheel_up"): # Zoom-In
			if spring_arm.spring_length > min_spring_length:
				spring_arm.spring_length -= spring_arm_length_step
		if Input.is_action_pressed("wheel_down"): # Zoom-Out
			if spring_arm.spring_length < max_spring_length:
				spring_arm.spring_length += spring_arm_length_step

func _grab_mouse() -> void:
	# Toggle mouse capture
	if Input.is_action_just_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _switch_camera() -> void:
	if Input.is_action_just_pressed("toggle_camera") and can_switch == true:
		if active_camera == fps_camera:
			active_camera = tps_camera
		else:
			active_camera = fps_camera
		# Now set current Camera based on camera switch.
		fps_camera.current = (active_camera == fps_camera)
		tps_camera.current = (active_camera == tps_camera)
