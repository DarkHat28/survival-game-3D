extends RigidBody3D ##Motolov.gd

var can_blast: bool = false
var blast_size: float = 3.0


func _process(delta: float) -> void:
	if can_blast:
		blast_size += 2 * delta
		
		#fire.get_child(1).material_override.set_shader_parameter('particle_scale_x' ,blast_size  )
		#fire.get_child(1).material_override.set_shader_parameter('particle_scale_y' ,blast_size  )

func _on_body_entered(_body: Node) -> void:
	
	rotation_degrees = Vector3.ZERO
	max_contacts_reported = 0
	freeze = true
	can_blast = true
	
	%Mesh.hide()
	
	await get_tree().create_timer(12).timeout
	queue_free()
