extends Node3D

@export var musicPlayer:AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicPlayer.stream.loop = true
	musicPlayer.play()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
