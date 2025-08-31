extends Control

# Node
@export var player: CharacterBody3D

# Reticle
@export var reticle_lines: Array[Line2D]
@export var reticle_line_color: Color = Color.RED # Single color for all reticle lines
@export var reticle_speed: float = 0.25
@export var reticle_distance: float = 2.0

# Dot
@export var dot_radius: float = 1.0  # Increased from 1.0 for better visibility
@export var dot_color: Color = Color.WHITE

func _ready() -> void:
	queue_redraw()
	apply_line_colors()

func _process(_delta: float) -> void:
	adjust_reticle_lines()

func _draw() -> void:
	# Draw at the center of the screen (which is the center of this full-screen control)
	var center = size / 2
	draw_circle(center, dot_radius, dot_color)

func adjust_reticle_lines():
	var vel: Vector3 = player.velocity
	var origin: Vector3 = Vector3.ZERO
	var pos: Vector2 = Vector2.ZERO
	var speed: float = origin.distance_to(vel) 
	
	# Adjust Reticle line positions
	reticle_lines[0].position = lerp(reticle_lines[0].position, pos + Vector2(-speed * reticle_distance, 0.0), 1) #Left
	reticle_lines[1].position = lerp(reticle_lines[1].position, pos + Vector2(speed * reticle_distance, 0.0), 1.0) #Right
	reticle_lines[2].position = lerp(reticle_lines[2].position, pos + Vector2(0.0, -speed * reticle_distance), 1.0) #Top
	reticle_lines[3].position = lerp(reticle_lines[3].position, Vector2(0.0, speed * reticle_distance), 1.0) #Bottom

func apply_line_colors():
	for line in reticle_lines:
		line.default_color = reticle_line_color
