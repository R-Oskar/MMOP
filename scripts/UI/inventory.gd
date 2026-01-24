extends Control

@export var player:CharacterBody3D
@export var hotbar: Control

var inventory_items: Array[Array] = [
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null]
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			close_inventory()
		else:
			open_inventory()


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
func load_item_to_inventory(item_id, row := 0, index := 0, count := 1) -> void:
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

## Loads all items from the hotbar (both visually and in code) to row_0 of the inventory.
func load_hotbar_items() -> void:
	var items = hotbar.get_hotbar_items()
	
	for i in range(items.size()):
		var item = items[i]
		
		if not item:
			clear_inventory_slot(0, i)
			continue
		
		load_item_to_inventory(item.item_id, 0, i, item.count)

func open_inventory() -> void:
	hotbar.hide()
	visible = true
	player.enable_input(false)
	load_hotbar_items()

func close_inventory() -> void:
	hotbar.show()
	visible = false
	player.enable_input(true)
