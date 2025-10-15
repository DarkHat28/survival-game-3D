class_name Player
extends CharacterBody3D

## TODO:  ADD GUN AND ITS ANIMATION

#region Entire Code
#region Variables
@export var state_chart: StateChart
@onready var state_label: Label = %StateLabel
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer
#@onready var player_camera: PlayerCamera = %PlayerCamera
#@export var animation_player: AnimationPlayer

@export_group("Movement")
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 30.0
@export var friction: float = 50.0
@export var lerp_player_rotation: float = 180.0

@export_group("Dash")
@export var dash_speed: float = 10.0 # How fast the dash should be (in seconds)
@export var dash_distance: float = 3.0  # How far the dash should travel (in meteres)
@export var dash_time: float = 0.2

@export_group("Jump")
@export var garvity_off: bool = false
@export var jump_height: float = 2.25
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3
# Calculated 
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak * -1
@onready var jump_gravity: float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
# @onready var wall_slide_gravity: float = fall_gravity / 10
# source: https://youtu.be/IOe1aGY6hXA?feature=shared



# Inbuilt Variables
var input_dir: Vector2
var direction: Vector3
var is_sprinting: bool = false
var is_jumping: bool = false
var last_direction: Vector3
var can_dash: bool = true
#endregion

## state_chart.get_active_state() == "JumpState" # How to check current State
func _ready() -> void:
	Global.player = self


func _physics_process(_delta: float) -> void:
	handle_transition()
	update_state_label()
	move_and_slide()

func _input(_event: InputEvent) -> void:
	# Update Input booleans
	is_jumping = Input.is_action_just_pressed("jump")
	is_sprinting = Input.is_action_pressed("sprint")
	
	# Get input direction
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	# Rotate input relative to camera orientation
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


#region Helper Functions
func start_horizontal_velocity(delta: float, speed: float = walk_speed) -> void: # Start moving
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * acceleration)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * acceleration)

func stop_horizontal_velocity(delta: float) -> void: # Stop moving
	velocity.x = move_toward(velocity.x, 0, delta * friction)
	velocity.z = move_toward(velocity.z, 0, delta * friction)
#endregion

func apply_gravity(delta: float) -> void:
	# Use appropriate gravity based on whether ascending or descending
	var gravity: float = jump_gravity if velocity.y > 0.0 else fall_gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = min(velocity.y, gravity) # Limit fall speed
		#print("If Not is-on-floor: ", gravity)
	#print("If is-on-floor: ", gravity)

func update_state_label() -> void:
	if state_label:
		state_label.text = "Can Dash: " + str(can_dash) +\
		"\nOn Wall: " + str(is_on_wall()) +\
		"\nVelocity: " + str(velocity)
#endregion


func handle_transition() -> void:
	# Grounded
	if input_dir:
		state_chart.send_event("input_movement")
		if is_sprinting:
			state_chart.send_event("sprinting")
	else:
		state_chart.send_event("stopped_movement")
	
	# Airborne
	if is_jumping:
		state_chart.send_event("jumping")
	
	# Dash input
	if Input.is_action_just_pressed("dash") and can_dash:
		state_chart.send_event("dashing")
	
	if not is_on_floor():
		if velocity.y < 0.0:
			state_chart.send_event("falling")
		else:
			state_chart.send_event("in_air")
	else:
		state_chart.send_event("on_ground")


# State Machine Logic Code
func _on_idle_state_physics_processing(delta: float) -> void:
	stop_horizontal_velocity(delta)

func _on_walk_state_physics_processing(delta: float) -> void:
	start_horizontal_velocity(delta)

func _on_sprint_state_processing(delta: float) -> void:
	start_horizontal_velocity(delta, sprint_speed)

func _on_jump_state_state_entered() -> void:
	velocity.y = -jump_velocity

func _on_jump_state_physics_processing(delta: float) -> void:
	start_horizontal_velocity(delta)
	apply_gravity(delta)

func _on_fall_state_physics_processing(delta: float) -> void:
	apply_gravity(delta)
	#if is_on_wall():
	#start_horizontal_velocity(delta)

# Dash Logic
func _on_dash_state_entered() -> void:
	# Transition delay time from %DashToIdle.delay-in_seconds (this is our dash duration)
	dash_time = float(%DashToIdle.delay_in_seconds)
	# Calculate required speed to cover the desired distance in the given duration
	dash_speed = dash_distance / dash_time
	
	# Set dash velocity in the direction player is facing (camera direction)
	var dash_direction = -transform.basis.z  # Forward vector of the player
	velocity.x = dash_direction.x * dash_speed
	velocity.z = dash_direction.z * dash_speed
	velocity.y = 0  # No gravity effect during dash

func _on_dash_state_exited() -> void:
	can_dash = false
	dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
