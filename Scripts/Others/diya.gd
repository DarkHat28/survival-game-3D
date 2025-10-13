extends Node3D


@onready var oil: MeshInstance3D = %Oil
var on :bool = false
var filled : bool = false

func _update(have_oil: bool, _mode: bool = false):
	oil.visible = have_oil
