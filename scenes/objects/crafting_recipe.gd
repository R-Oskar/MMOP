extends Button

var inventory: Control

@export var recipe_label: RichTextLabel # Changed to RichTextLabel
@export var amount_required: int = 4
@export var item_name: String = "Stone"

func _ready():
	inventory = get_tree().get_first_node_in_group("InventoryUI")
	recipe_label.bbcode_enabled = true
	
	# This allows clicks to pass through the label to the button
	recipe_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_current_amount() -> void:
	# 1. Get the items from inventory
	var locations = inventory.inventory_contains(ItemIDs.ItemID.STONE)
	var total = inventory.get_total_from_locations(locations)
	
	# 2. Determine the color string
	var color_code = "green" if total >= amount_required else "red"
	
	# 3. Construct BBCode string: "[color=red]0[/color]/4 Stone"
	recipe_label.text = "[color=%s]%d[/color] / %d %s" % [color_code, total, amount_required, item_name]

	disabled = total < amount_required
