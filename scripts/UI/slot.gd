extends TextureRect

@export var slot_identification:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("TopLeft").text = slot_identification
