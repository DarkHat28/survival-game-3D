extends CharacterBody3D

#@onready var walking_sound = $walking
#@onready var running_sound = $running
#@onready var jump_sound = $jump
@onready var cam=$Camera3D


@onready var speed :float= 250
const JUMP_VELOCITY :float= 5.0
const Walk_speed = 170
const Sprint_speed = 400

var dir : Vector2
var holding_sprint = false
var breathein = true

@export var camera_sensitivity :int= 50 #1 to 100 only,baaki v ho skte hai wese...

var gravity :float = 12.0

var sprint_lerp_time = 10
var sprint_bobbing_normal_speed :float = 20.0
var sprint_bobbing_normal_ind :float = 0.25
var sprint_bobbing_index:float = 0.0
var sprint_bobbing_vector = Vector2.ZERO

var idle_lerp_time = 5
var idle_bobbing_normal_speed :float = 1.0
var idle_bobbing_normal_ind :float = 0.01
var idle_bobbing_index:float = 0.0
var idle_bobbing_vector = Vector2.ZERO

var walk_lerp_time = 10
var walk_bobbing_normal_speed :float = 12.0
var walk_bobbing_normal_ind :float = 0.12
var walk_bobbing_index:float = 0.0
var walk_bobbing_vector = Vector2.ZERO

func update_cam_movement(delta):
	sprint_bobbing_index += sprint_bobbing_normal_speed *delta
	idle_bobbing_index += idle_bobbing_normal_speed * delta
	walk_bobbing_index += walk_bobbing_normal_speed * delta
	
	if(is_on_floor() and dir != Vector2.ZERO and holding_sprint):
		sprint_bobbing_vector.y  = sin(sprint_bobbing_index)
		sprint_bobbing_vector.x = sin(sprint_bobbing_index/2)/2.0
		cam.position.y = lerp(cam.position.y ,cam.position.y+ sprint_bobbing_vector.y * (sprint_bobbing_normal_ind/2.0 ), delta * sprint_lerp_time)
		cam.position.x = lerp(cam.position.x ,cam.position.x+ sprint_bobbing_vector.x * sprint_bobbing_normal_ind, delta * sprint_lerp_time)
		
	if(is_on_floor() and dir == Vector2.ZERO):
		idle_bobbing_vector.y  = sin(idle_bobbing_index)
		cam.position.y = lerp(cam.position.y ,cam.position.y+ idle_bobbing_vector.y * idle_bobbing_normal_ind, delta * idle_lerp_time)

	if(is_on_floor() and dir != Vector2.ZERO and not holding_sprint):
		walk_bobbing_vector.y  = sin(walk_bobbing_index)
		walk_bobbing_vector.x = sin(walk_bobbing_index/2)/2.0
		cam.position.y = lerp(cam.position.y ,cam.position.y+ walk_bobbing_vector.y * (walk_bobbing_normal_ind/2.0 ), delta * walk_lerp_time)
		cam.position.x = lerp(cam.position.x ,cam.position.x+ walk_bobbing_vector.x * walk_bobbing_normal_ind, delta * walk_lerp_time)
		

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if Input.is_action_just_pressed("sprint"):
		holding_sprint = true
		speed = Sprint_speed
	if Input.is_action_just_released("sprint"):
		holding_sprint=false
		speed = Walk_speed
			
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		cam.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		cam.rotation.x = clamp(cam.rotation.x , -PI/2,PI/2)
	

func _physics_process(delta):
	dir = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized()
	update_cam_movement(delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		#jump_sound.play()
	var direction = (transform.basis * Vector3(dir.x, 0, dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed *delta
		velocity.z = direction.z * speed *delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed*delta)
		velocity.z = move_toward(velocity.z, 0, speed*delta)
	move_and_slide()
	
	#if(dir != Vector2.ZERO and holding_sprint and not running_sound.playing):
		#pass
		##running_sound.play()
	#if(dir != Vector2.ZERO and not holding_sprint and not Global.hiddeninsidebush and not walking_sound.playing and not Global.in_lock_screen):
		#pass
		#walking_sound.play()
	#if Global.hiddeninsidebush or dir==Vector2.ZERO or Global.in_lock_screen:
		#pass
		#running_sound.stop()
		#walking_sound.stop()
