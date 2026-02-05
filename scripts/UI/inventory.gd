extends Control

@export var player:CharacterBody3D
@export var hotbar: Control
@onready var chest: Control = get_node("Chest")
@onready var crafting_table: Control = get_node("CraftingTable")

# row 0 for hotbar, row 6 for chests
var inventory_items: Array[Array] = [
	[null, null, null, null, null, null, null, null, null, null],
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
	hide()
	chest.hide()
	crafting_table.hide()

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

	var row_node
	
	if row < 5:
		row_node = get_node("row_%d" % (row ))
	else:
		row_node = get_node("Chest/row_%d" % (row ))
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
	
	var item: Item = ItemIDs.get_item(item_id)
	inventory_items[row][index] = item
	item.count = count
	
	var row_node
	
	if row < 5:
		row_node = get_node("row_%d" % (row ))
	else:
		row_node = get_node("Chest/row_%d" % (row ))
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

	var row_node
	if row < 5:
		row_node = get_node("row_%d" % row)
	else:
		row_node = get_node("Chest/row_%d" % row)
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

func open_chest(opened_chest:  StaticBody3D) -> void:
	var chest_items = opened_chest.chest_items
	
	open_inventory()
	chest.show()
	
	for i in chest_items.size():
		var item = chest_items[i]
		if item:
			load_item_to_inventory(item.item_id, 5, i, item.count)

func close_chest(opened_chest: StaticBody3D) -> void:
	close_inventory()
	chest.hide()
	var chest_items = opened_chest.chest_items
	
	opened_chest.update(inventory_items[5])
	
	for i in chest_items.size():
		clear_inventory_slot(5, i)

func open_crafting_table():
	open_inventory()
	crafting_table.show()
	crafting_table.get_node("CraftingRecipe").update_current_amount()

func close_crafting_table():
	close_inventory()
	crafting_table.hide()

## Returns the total amount of a specific item currently held in the inventory.
## Update the first line to accept the Enum type
func inventory_contains(target_id: ItemIDs.ItemID) -> Dictionary:
	var locations = {}
	
	for row_index in range(inventory_items.size()):
		var row = inventory_items[row_index]
		for slot_index in range(row.size()):
			var item = row[slot_index]
			
			# Now we are comparing int to int (the enum values)
			if item != null and item.item_id == target_id:
				var coords = Vector2(row_index, slot_index)
				locations[coords] = item.count
				
	return locations

## Takes the dictionary from inventory_contains and returns the total sum of items.
func get_total_from_locations(locations: Dictionary) -> int:
	var sum: int = 0
	for count in locations.values():
		sum += count
	return sum

func _on_crafting_recipe_pressed() -> void:
	pass # Replace with function body.
