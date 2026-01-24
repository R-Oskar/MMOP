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
	close_inventory()

func _input(event):
	if event.is_action_pressed("inventory"):
		if visible:
			close_inventory()
		else:
			open_inventory()

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

func load_item_to_inventory(item_id, row := 0, index := 0, count := 1):
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

func load_hotbar_items():
	var items = hotbar.get_hotbar_items()
	
	for i in range(items.size()):
		var item = items[i]
		
		if not item:
			clear_inventory_slot(0, i)
			continue
		
		load_item_to_inventory(item.item_id, 0, i, item.count)
		

func open_inventory():
	hotbar.hide()
	visible = true
	player.toggle_input(false)
	load_hotbar_items()
	get_tree().paused = true
	
func close_inventory():
	hotbar.show()
	visible = false
	player.toggle_input(true)
	get_tree().paused = false
