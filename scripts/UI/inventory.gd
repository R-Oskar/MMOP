extends Control

@export var player:CharacterBody3D
@export var hotbar: Control

var inventory_items: Array[Array] = [
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null]
]

func get_hotbar_items() -> Array:
	return inventory_items[0]

func get_hotbar_item(index: int) -> Item:
	return inventory_items[0][index]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event) -> void:
	if event.is_action_pressed("inventory"):
		player.clear_preview()
		if visible:
			close_inventory()
		else:
			open_inventory()

func swap_inventory_slots(originalRow, originalIndex, row,index) -> void:
	var item = inventory_items[originalRow][originalIndex]
	clear_inventory_slot(originalRow, originalIndex)
	load_item_to_inventory(item.item_id, row, index, item.count)

## Removes item (both visually and in code) from the inventory at given row and index.
func clear_inventory_slot(row: int, index: int) -> void:
	inventory_items[row][index] = null

	var row_node = get_node("row_%d" % row)
	var slot_node = row_node.get_child(index)

	var icon_node = slot_node.get_node("Item") as TextureRect
	if icon_node:
		icon_node.texture = null

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = ""

## Load a item (identified by ItemID) at specified row and specified index with specified count to the inventory.
func load_item_to_inventory(item_id, row := 0, index := 0, count := 1) -> Item:
	var original_item = inventory_items[row][index]
	
	if original_item and original_item.item_id != item_id:
		return
	
	if original_item and original_item.item_id == item_id:
		#inventory_items[row][index].count += count
		change_count(count, row, index)
		return
	
	var item: Item = ItemIDs.ITEM_REGISTRY[item_id].duplicate()
	inventory_items[row][index] = item
	item.count = count
	
	var row_node = get_node("row_%d" % (row ))
	var slot_node = row_node.get_child(index)
	var icon_node = slot_node.get_node("Item") as TextureRect
	icon_node.texture = item.icon

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)
	return item

func change_count(number: int, row: int, index: int) -> void:
	var item: Item = inventory_items[row][index]
	if item == null:
		return

	item.count += number

	# If count is zero or less, remove the item completely
	if item.count <= 0:
		clear_inventory_slot(row, index)
		return

	# Update the UI count label
	var row_node = get_node("row_%d" % row)
	var slot_node = row_node.get_child(index)
	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)

func open_inventory() -> void:
	hotbar.hide()
	visible = true
	player.enable_input(false)

func close_inventory() -> void:
	hotbar.show()
	visible = false
	player.enable_input(true)
	hotbar.update_hotbar_ui()
