extends Node

var player: Player = null # reference to player root Node

var can_rotate_cam: bool = true
# Updated upstream
#var player_pos :Vector3 = Vector3.ZERO #Iski zarurat jkaha pe hai bro?
var input_dir: Vector2 = Vector2.ZERO


## Weapon And Grenade Variables
var ammo: int = 1000
var gas: int = 100

var player_pos :Vector3 = Vector3.ZERO
var dir :Vector2 = Vector2.ZERO
var targets :Array= [] #diya pos
