
extends ProgressBar

var health :int= 0 : set = _set_health
var speed : float = 40

func _ready():
	Global.connect("change_health",_change_health)

func _init_health(_health : int):
	health = _health
	max_value = health
	value=health
	$DamageBar.max_value = health
	$DamageBar.value=health
	
func _set_health(new_health):
	var prev_health := health
	health = min(max_value,new_health)
	value = health
	if(health<=0):
		queue_free()
		die()
	if(health<prev_health):
		$Timer.start()
	else:
		$DamageBar.value = health
		

func die():
	pass

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($DamageBar,"value",health,($DamageBar.value-value)/speed)

func _change_health(new_health):
	_set_health(new_health)
