extends Node

var on :bool = false
var filled : bool = false

func _update(have_oil:bool,mode:bool = false):
	$oil.visible = have_oil
	pass
	
