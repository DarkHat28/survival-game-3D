class_name PlayerStateMachine
extends CharacterBody3D

#region Entire Code
#region Variables
@export_group("State Variables")
enum PlayerState {IDLE, MOVE, JUMP, FALL}
@export var current_state: PlayerState = PlayerState.IDLE
@export var previous_state: PlayerState = PlayerState.IDLE

@export_group("Nodes")
@export var player_avatar: Node3D # Player Avatar Child Node will be in this export var not PlayerAvatar Node
@export var camera_logic: Node3D
@export var camera: Camera3D
@export var animation_player: AnimationPlayer
@export var state_label: Label
@export var standing_collision_shape: CollisionShape3D
#@export var crouch_collision_shape: CollisionShape3D
#@export var prone_collision_shape: CollisionShape3D

@export_group("Movement")
@export var base_speed := 5.0
@export var sprint_speed := 7.0
#@export var speed_modifier := 1.0
@export var acceleration: float = 30.0
@export var friction: float = 50.0
@export var lerp_player_rotation: float = 180.0


@export_group("Jump")
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
# Calculated 
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
#@onready var wall_slide_gravity: float = fall_gravity / 10
# source: https://youtu.be/IOe1aGY6hXA?feature=shared

# Input
var input_dir: Vector2
var rotated_input: Vector2
var direction: Vector3
var last_input_dir: Vector2

# bool
var is_sprinting: bool = false
var was_in_air: bool= false
var on_floor: bool = false

#endregion

#region Core Functions
func _ready() -> void:
	Global.player = self
	player_avatar.rotation.y = camera_logic.rotation.y + PI

func _physics_process(delta: float) -> void:
	# print(($Head.global_position - $CameraLogic/TPSPivot/SpringArm/TPSCamera.global_position).length())
	input()
	# Rotate input relative to camera orientation
	if not camera_logic.is_free_looking:
		rotated_input = input_dir.rotated(-camera.global_rotation.y)
	# Convert to 3D direction
	direction = Vector3(rotated_input.x, 0, rotated_input.y)
	# Normalize so diagonal movement isn’t faster
	if direction.length() > 0:
		direction = direction.normalized()
	# functions
	handle_state(delta)
	update_state_label()
	#apply_gravity(delta)
	move_and_slide()
	
func input() -> void:
	# Get 2D movement input relative to camera rotation # Get 2D movement input (X/Z plane)
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_sprinting = Input.is_action_pressed("sprint")


#endregion

#region State Machine
func handle_state(delta: float) -> void:
	match current_state:
		PlayerState.IDLE:
			state_idle(delta)
		PlayerState.MOVE: # Horizontal movement
			state_move(delta)
		PlayerState.JUMP: # Vertical movement
			state_jump(delta) 
		PlayerState.FALL: # Vertical movement
			state_fall(delta)
	rotate_player_avatar(delta)
	update_animation()

func state_idle(delta: float) -> void:
	stop_horizontal_velocity(delta)
	if Input.is_action_just_pressed("jump"):
		change_state(PlayerState.JUMP)
	if is_on_floor():
		if input_dir != Vector2.ZERO:
			change_state(PlayerState.MOVE)
	else:
		change_state(PlayerState.FALL)

func state_move(delta: float) -> void:
	var speed = sprint_speed if is_sprinting else base_speed
	if input_dir != Vector2.ZERO:
		# Apply movement
		start_horizontal_velocity(delta, speed)
		var target_angle = -input_dir.angle() + PI/2
		player_avatar.rotation.y = rotate_toward(player_avatar.rotation.y, target_angle, lerp_player_rotation * delta)
	else:
		stop_horizontal_velocity(delta)
	if input_dir:
		last_input_dir = input_dir.normalized()
	
	if is_on_floor():
		if input_dir == Vector2.ZERO:
			change_state(PlayerState.IDLE)
		if Input.is_action_just_pressed("jump"):
			change_state(PlayerState.JUMP)
	else:
		change_state(PlayerState.FALL)

func state_jump(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	change_state(PlayerState.FALL)
	apply_gravity(delta)
		# Only apply jump velocity once when entering the state
		#if previous_state != PlayerState.JUMP  and current_state == PlayerState.FALL:
			#velocity.y = jump_velocity
		## Transition to fall when starting to descend
		#if velocity.y >= 0:
			#change_state(PlayerState.FALL)

func state_fall(delta: float) -> void:
	#stop_horizontal_velocity(delta)
	if input_dir != Vector2.ZERO: # Allow some horizontal movement in air
		var air_speed = base_speed * 0.7  # Reduced air control
		start_horizontal_velocity(delta, air_speed)
	apply_gravity(delta)
	if is_on_floor():
		if input_dir != Vector2.ZERO:
			change_state(PlayerState.MOVE)
		else:
			change_state(PlayerState.IDLE)
#endregion

func rotate_player_avatar(delta:float) -> void:
	var target_angle = input_dir.angle()
	if input_dir:
		player_avatar.rotation.y = -target_angle + PI/2
		player_avatar.rotation.y = rotate_toward(player_avatar.rotation.y, target_angle, delta)

func change_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return
	# Handle exit logic for current state if any
	previous_state = current_state
	current_state = new_state
	# Handle entry logic for new state
	match new_state:
		PlayerState.JUMP:
			# Set jump velocity when entering jump state
			velocity.y = jump_velocity
			was_in_air = true

	previous_state = current_state
	current_state = new_state

func update_animation() -> void:
	if !animation_player:
		return
		
	match current_state:
		PlayerState.IDLE:
			animation_player.play(&"idle")
		PlayerState.MOVE:
			if is_sprinting:
				animation_player.play(&"sprint")
			else:
				animation_player.play(&"walk")
		PlayerState.JUMP:
			if velocity.y > 0:
				animation_player.play(&"Jump_Start")
			else:
				animation_player.play(&"Jump")  # Mid-air animation
		PlayerState.FALL:
			if is_on_floor():
				animation_player.play(&"Jump_Land", 0.2, 1.8)
				was_in_air = false
			else:
				animation_player.play(&"fall")

func apply_gravity(delta: float) -> void:
	match current_state:
		PlayerState.IDLE, PlayerState.MOVE:
			return
		PlayerState.JUMP, PlayerState.FALL:
			# Use appropriate gravity based on whether ascending or descending
			var gravity: float = jump_gravity if velocity.y > 0.0 else fall_gravity
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, gravity) # Limit fall speed
		# Only play jump/fall animation if not already playing landing or start
			if animation_player:
				if not animation_player.current_animation in ["Jump_Land", "Jump_Start"]:
					animation_player.play(&"Jump", 0.2) # Later convert it into FALL ANIMATION &"Fall"

#region Helper Functions
func stop_horizontal_velocity(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * friction)
	velocity.z = move_toward(velocity.z, 0, delta * friction)
	
func start_horizontal_velocity(delta: float, speed: float) -> void:
	# Apply movement
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * acceleration)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * acceleration)
#endregion

#region Temprory Debug Functions
func update_state_label() -> void:
	if state_label:
		state_label.text = "State:  " + PlayerState.keys()[current_state]\
		+ ("\nVelocity X: " + str(round(velocity.x))\
		+ "  Velocity Z: " + str(round(velocity.z))\
		+ "\nVelocity Y: " + str(round(velocity.y)))

#endregion

#func active_collision_shapes() -> void:
	#if full_collision_shape and half_collision_shape:
		#match current_state:
			#PlayerState.CROUCHING, PlayerState.CRAWLING:
				#full_collision_shape.disabled = true
				#half_collision_shape.disabled = false
			#_:
				#full_collision_shape.disabled = false
				#half_collision_shape.disabled = true
#endregion
