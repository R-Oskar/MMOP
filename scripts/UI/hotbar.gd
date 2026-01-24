extends Control

@export var player:CharacterBody3D
@onready var boxContainer: BoxContainer = $Slots

var hotbar_items: Array[Item] = [null, null, null, null, null, null, null, null, null, null]
var selected_index := 0

func _ready() -> void:
	load_item_to_hotbar(ItemIDs.ItemID.STONE, 2, 100)
	load_item_to_hotbar(ItemIDs.ItemID.STONE, 3, 10)

func _process(_delta: float) -> void:
	var item = hotbar_items[selected_index]
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
			if(player.last_preview):
				player.clear_preview()
			update_selection_position()
			break
		
	if Input.is_action_pressed("use_item"):
		var item = hotbar_items[selected_index]
		if item && player.try_to_use_item(item):
			reduce_item_count(item)
			update_hotbar_ui()


## Load a item (identified by ItemID) at specified index with specified count to the hotbar.
func load_item_to_hotbar(item_id, index := 0, count := 1) -> void:
	var item: Item = ItemIDs.ITEM_REGISTRY[item_id].duplicate()
	hotbar_items[index] = item
	item.count = count

	var slot_node = boxContainer.get_child(index)
	var icon_node = slot_node.get_node("Item") as TextureRect
	icon_node.texture = item.icon

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)

## Updates the position of the selection icon in the hotbar.
func update_selection_position() -> void:
	var target_position = Vector2(-1 + selected_index * 54, -1)
	$Select.position = target_position

## Reduces mentioned item count and removes it if needed from the hotbar.
func reduce_item_count(item: Item) -> void:
	if item.count > 0:
		item.count -= 1
	if item.count == 0:
		hotbar_items[selected_index] = null

## Displays the items from the hotbar array on the hotbar GUI with their count and texture.
func update_hotbar_ui() -> void:
	for i in range(hotbar_items.size()):
		var slot = boxContainer.get_child(i)
		var icon_node = slot.get_node("Item") as TextureRect
		var count_label = slot.get_node("Count") as RichTextLabel

		if hotbar_items[i]:
			icon_node.texture = hotbar_items[i].icon
			count_label.text = str(hotbar_items[i].count)
		else:
			icon_node.texture = null
			count_label.text = ""

## Returns the array of hotbar_items.
func get_hotbar_items() -> Array[Item]:
	return hotbar_items
