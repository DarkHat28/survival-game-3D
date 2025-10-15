extends Node3D

var firing :bool = false
var firing_cost :float = 50

func _unhandled_input(_event):
	if(Input.is_action_just_pressed("fire")):
		if(Global.ammo>0):
			firing = true
	if(Input.is_action_just_released("fire")):
		firing=false
		

func _process(delta):
	if(firing and Global.ammo>0):
		$GunFlame.visible = true
		$GunFlame/ShapeCast3D.enabled = true
		Global.ammo-=delta*firing_cost
	else:
		$GunFlame.visible = false
		$GunFlame/ShapeCast3D.enabled = false
	if(Global.ammo<=0):
		firing = false
	$CanvasLayer/ProgressBar.value = Global.ammo/10.0
