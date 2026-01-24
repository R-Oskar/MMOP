extends TextureRect

@export var slot_identification:String

func _ready() -> void:
	get_node("TopLeft").text = slot_identification
