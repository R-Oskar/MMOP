extends StaticBody3D

var inventory: Control
var is_open: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = get_tree().get_first_node_in_group("InventoryUI")

func toggle_crafting_table():
	is_open = not is_open
	
	if is_open:
		inventory.open_crafting_table()
	else:
		inventory.close_crafting_table()
