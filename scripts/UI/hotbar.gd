extends Control

@export var player:CharacterBody3D
@export var inventory: Control
@onready var boxContainer: BoxContainer = $Slots

var selected_index := 0

func _ready() -> void:
	$Select.position = Vector2(0,0)

func _process(_delta: float) -> void:
	var item = inventory.get_hotbar_item(selected_index)
	if item and item.scene:
		player.show_preview(item)

func _unhandled_input(_event: InputEvent) -> void:
	if not player.is_input_enabled():
		return
	
	for i in range(10):
		var action_name = "slot%d" % i
		if Input.is_action_just_pressed(action_name):
			if i == 0:
				selected_index = 9
			else:
				selected_index = i - 1
			player.clear_preview()
			update_selection_position()
			break
	
	if Input.is_action_pressed("use_item"):
		var item = inventory.get_hotbar_item(selected_index)
		if item && player.try_to_use_item(item):
			reduce_item_count(item)
			update_hotbar_ui()

## Load a item (identified by ItemID) at specified index with specified count to the hotbar.
func load_item_to_hotbar(item_id, index := 0, count := 1) -> void:
	inventory.load_item_to_inventory(item_id, 0, index, count)
	update_hotbar_ui()

## Updates the position of the selection icon in the hotbar.
func update_selection_position() -> void:
	var target_position = Vector2(selected_index * 54, 0)
	$Select.position = target_position

## Reduces mentioned item count and removes it if needed from the hotbar.
func reduce_item_count(item: Item) -> void:
	if item.count > 0:
		inventory.change_count(-1,0, selected_index)
	if item.count == 0:
		inventory.clear_inventory_slot(0, selected_index)

## Displays the items from the hotbar array on the hotbar GUI with their count and texture.
func update_hotbar_ui() -> void:
	for i in range(inventory.get_hotbar_items().size()):
		var slot = boxContainer.get_child(i)
		var icon_node = slot.get_node("Item") as TextureRect
		var count_label = slot.get_node("Count") as RichTextLabel
		
		var hotbar_new_items = inventory.get_hotbar_items()
		
		if hotbar_new_items[i]:
			icon_node.texture = hotbar_new_items[i].icon
			count_label.text = str(hotbar_new_items[i].count)
		else:
			icon_node.texture = null
			count_label.text = ""
