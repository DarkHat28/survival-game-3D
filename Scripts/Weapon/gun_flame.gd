extends GPUParticles3D

func _physics_process(_delta: float) -> void:
	if Global.player.velocity != Vector3.ZERO:
		print("Player Velocity: ", Global.player.velocity)
