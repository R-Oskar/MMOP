extends Control

@export var player:CharacterBody3D
@onready var boxContainer: BoxContainer = $Slots

var hotbar_items: Array[Item] = [null, null, null, null, null, null, null, null, null, null]
var selected_index := 0

func _ready():
	load_item_to_hotbar(ItemIDs.ItemID.STONE, 2, 100)
	load_item_to_hotbar(ItemIDs.ItemID.STONE, 3, 10)

func _process(_delta: float) -> void:
	var item = hotbar_items[selected_index]
	if item and item.scene:
		player.show_preview(item)

func load_item_to_hotbar(item_id, index := 0, count := 1):
	var item: Item = ItemIDs.ITEM_REGISTRY[item_id].duplicate()
	hotbar_items[index] = item
	item.count = count

	var slot_node = boxContainer.get_child(index)
	var icon_node = slot_node.get_node("Item") as TextureRect
	icon_node.texture = item.icon

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)

func _unhandled_input(_event: InputEvent) -> void:
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
			play_sound(item.sound)

func update_selection_position():
	var target_position = Vector2(-1 + selected_index * 54, -1)
	$Select.position = target_position

func play_sound(sound):
	var music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = sound
	music_player.play()

func reduce_item_count(item):
	if item.count > 0:
		item.count -= 1
	if item.count == 0:
		hotbar_items[selected_index] = null

func update_hotbar_ui():
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

func get_hotbar_items():
	return hotbar_items
