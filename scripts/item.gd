# Item.gd
extends Resource

class_name Item

@export var name: String
@export var icon: Texture2D
@export var count: int = 1
@export var scene: PackedScene  # Reference to the placeable scene
@export var sound: AudioStreamMP3
