extends Control

@export var inventory_ui: Control
@export var row: int
@export var index: int

@export var slot_identification: String

func _ready() -> void:  
	# Safety check to ensure the label exists
	if has_node("TopLeft"):
		get_node("TopLeft").text = slot_identification  

func _get_drag_data(_pos):
	var item = inventory_ui.inventory_items[row][index]
	if item == null:
		return null

	# Create a container for the preview
	var root := Control.new()

	# Create the icon
	var icon := TextureRect.new()
	icon.texture = item.icon
	# Set a fixed size or scale that makes sense for your UI
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(40, 40)
	# Center the preview on the mouse cursor
	icon.position = -icon.custom_minimum_size / 2 
	root.add_child(icon)

	# Number label
	if item.count > 1:
		var label := Label.new()
		label.text = str(item.count) 
		label.position = Vector2(10, 5) # Adjust based on your icon size
		root.add_child(label)

	set_drag_preview(root)

	# Return the source coordinates so the inventory knows where the item CAME from
	return {
		"row": row,
		"index": index,
		"item": item
	}

func _can_drop_data(_pos, data):
	# We can drop if the data dictionary contains a row and index
	return data is Dictionary and data.has("row") and data.has("index")

func _drop_data(_pos, data):
	# If the item is dropped on itself, do nothing
	if data.row == self.row and data.index == self.index:
		return

	# Otherwise, proceed with the swap
	inventory_ui.swap_inventory_slots(
		data.row,
		data.index,
		self.row,
		self.index
	)
