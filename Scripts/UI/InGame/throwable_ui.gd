class_name GrenadeUI
extends Control

@onready var grenade_icon: TextureButton = %GrenadeIcon
#@onready var grenade_icon: TextureRect = %GrenadeIcon
@onready var grenade_list: VBoxContainer = %GrenadeList
@onready var frag_grenade: TextureButton = %FragGrenade
@onready var motolov: TextureButton = %Motolov

enum GrenadeType { FRAG, MOLOTOV }
@export var current_grenade: GrenadeType = GrenadeType.FRAG


func _ready():
	update_texture()
	# All connections will be made in the editor
	grenade_list.visible = false
	#grenade_icon.texture_normal = current_grenade.texture_normal

func toggle_list():
	grenade_list.visible = !grenade_list.visible

func _on_grenade_icon_pressed():
	toggle_list()


func _on_frag_grenade_pressed():
	current_grenade = GrenadeType.FRAG

func _on_motolov_pressed() -> void:
	current_grenade = GrenadeType.MOLOTOV

func update_texture() -> void:
	match current_grenade:
		GrenadeType.FRAG:
			print("Frag Texture")
			grenade_icon.texture_normal = %FragGrenade.texture_normal
		
		GrenadeType.MOLOTOV:
			print("Motolov Texture")
			grenade_icon.texture_normal = %Motolov.texture_normal
	
