extends Resource

class_name Item

const ItemScript = preload("res://items/item_ids.gd")

@export var name: String
@export var icon: Texture2D
@export var count: int = 1
@export var scene: PackedScene
@export var sound: AudioStreamMP3
@export var item_id: ItemScript.ItemID
