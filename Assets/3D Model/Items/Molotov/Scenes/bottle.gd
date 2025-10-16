extends RigidBody3D
@onready var fire = $fire
# Called every frame. 'delta' is the elapsed time since the previous frame.
var can_blast = false
var blast_size = 3

func _process(delta):
	if can_blast:
		blast_size += 2 * delta
		fire.get_child(1).material_override.set_shader_parameter('particle_scale_x' ,blast_size  )
		fire.get_child(1).material_override.set_shader_parameter('particle_scale_y' ,blast_size  )
func _on_body_entered(body):
	rotation_degrees = Vector3.ZERO
	max_contacts_reported = 0
	freeze = true
	$CollisionShape3D.set_deferred("disabled" ,true)
	
	can_blast = true
	
	$Area3D.monitoring = true
	
	fire.get_child(0).emitting = true
	fire.get_child(1).emitting = true
	fire.get_child(1).get_child(0).emitting = true
	fire.get_child(1).get_child(1).emitting = true
	$Bottle.hide()
	await get_tree().create_timer(18).timeout
	queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= 30
		
