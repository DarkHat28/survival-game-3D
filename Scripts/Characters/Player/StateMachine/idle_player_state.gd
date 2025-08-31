class_name IdlePlayerState extends State

func update(delta: float):
	if Global.player.velocity.length() > 0.0:
		transition.emit("WalkingPlayerState")
