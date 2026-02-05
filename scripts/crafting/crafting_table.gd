extends StaticBody3D

var inventory: Control
var is_open: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = get_tree().get_first_node_in_group("InventoryUI")

func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel")):
		toggle_crafting_table()

func toggle_crafting_table():
	is_open = not is_open
	
	if is_open:
		inventory.open_crafting_table()
	else:
		inventory.close_crafting_table()
