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

	var preview = TextureRect.new()
	preview.texture = item.icon
	preview.custom_minimum_size = Vector2(48, 48)
	set_drag_preview(preview)

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
