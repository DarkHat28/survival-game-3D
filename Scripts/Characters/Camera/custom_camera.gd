@icon("res://icon.svg")
class_name CustomCamera3D extends Node3D

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera_body: CharacterBody3D = %CameraBody
@onready var camera: Camera3D = %Camera
@onready var ray_cast: RayCast3D = %RayCast
