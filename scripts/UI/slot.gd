extends Control

@export var inventory_ui: Control
@export var row: int
@export var index: int

@export var slot_identification:String

func _ready() -> void:  
	get_node("TopLeft").text = slot_identification  

func _get_drag_data(_pos):
	var item = inventory_ui.inventory_items[row][index]
	if item == null:
		return null

	var root := Control.new()

	var icon := TextureRect.new()
	icon.texture = item.icon
	icon.scale = Vector2(0.1,0.1)
	root.add_child(icon)

	# Number label
	var label := Label.new()
	label.text = str(item.count) 
	label.offset_left = 32
	label.offset_top = 20

	root.add_child(label)

	set_drag_preview(root)

	return {
		"row": row,
		"index": index,
		"item": item
	}

func _can_drop_data(_pos, data):
	return data.has("item")

func _drop_data(_pos, data):
	inventory_ui.swap_inventory_slots(
		data.row,
		data.index,
		row,
		index
	)
