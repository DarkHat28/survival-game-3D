class_name GrenadeUI
extends Control

@onready var frag_grenade: Button = %FragGrenade
@onready var motolov_cocktail: Button = %MotolovCocktail
@onready var grenade_icon: Button = %GrenadeIcon
@onready var container: PanelContainer = %Container

enum GrenadeType { FRAG, MOLOTOV }
@export var current_grenade: GrenadeType = GrenadeType.FRAG


func _ready():
	container.visible = false
	update_texture()

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grenade_1"):
		_on_frag_grenade_pressed()
		toggle_list()
		
	if Input.is_action_just_pressed("grenade_2"):
		_on_motolov_cocktail_pressed()
		toggle_list()


func toggle_list():
	container.visible = !container.visible


func _on_grenade_icon_pressed():
	toggle_list()

func _on_frag_grenade_pressed():
	current_grenade = GrenadeType.FRAG
	toggle_list()
	update_texture()

func _on_motolov_cocktail_pressed() -> void:
	current_grenade = GrenadeType.MOLOTOV
	toggle_list()
	update_texture()


func update_texture() -> void:
	match current_grenade:
		GrenadeType.FRAG:
			grenade_icon.icon = frag_grenade.icon
			grenade_icon.text = frag_grenade.text
			frag_grenade.disabled = true
			motolov_cocktail.disabled = false
		
		GrenadeType.MOLOTOV:
			grenade_icon.icon = motolov_cocktail.icon
			grenade_icon.text = motolov_cocktail.text
			frag_grenade.disabled = false
			motolov_cocktail.disabled = true
