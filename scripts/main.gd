extends Node3D

@export var musicPlayer:AudioStreamPlayer

func _ready() -> void:
	musicPlayer.stream.loop = true
	musicPlayer.play()
