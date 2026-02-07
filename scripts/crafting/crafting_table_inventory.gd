extends VBoxContainer

@export var inventory: Control
@export var crafting_sound: AudioStreamPlayer

func _ready():
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child))

func _on_button_pressed(button: Button):
	var recipe = button.recipe
	var ingredient_id = recipe.ingredients.keys()[0]
	var required_amount = recipe.ingredients[ingredient_id]
	var result_id = recipe.result_item
	
	# 1. Check ingredients
	var locations = inventory.inventory_contains(ingredient_id)
	var total = inventory.get_total_from_locations(locations)
	
	if total < required_amount:
		print("Not enough ingredients!")
		return

	# 2. Find where to put the result (Stack first, then Empty)
	var target_slot = find_stackable_or_empty(result_id)
	if target_slot == Vector2(-1, -1):
		print("Inventory full!")
		return

	# 3. Consume ingredients
	var remaining_to_consume = required_amount
	crafting_sound.play()
	
	for coords in locations.keys():
		if remaining_to_consume <= 0: break
		var row = int(coords.x)
		var col = int(coords.y)
		var amount_in_slot = locations[coords]
		
		if amount_in_slot <= remaining_to_consume:
			remaining_to_consume -= amount_in_slot
			inventory.clear_inventory_slot(row, col)
		else:
			inventory.change_count(-remaining_to_consume, row, col)
			remaining_to_consume = 0

	# 4. Add the item (load_item_to_inventory handles both new and existing stacks)
	inventory.load_item_to_inventory(result_id, int(target_slot.x), int(target_slot.y), 1)
	
	button.update_current_amount()

## Searches for an existing stack of the same ID, or the first empty slot.
func find_stackable_or_empty(item_id) -> Vector2:
	var first_empty = Vector2(-1, -1)
	
	# Loop through player inventory (Rows 0-4)
	for r in range(5):
		for c in range(inventory.inventory_items[r].size()):
			var item = inventory.inventory_items[r][c]
			
			# If we find the same item, return this coordinate immediately (Stacking)
			if item != null and item.item_id == item_id:
				return Vector2(r, c)
			
			# If we find an empty slot, remember the FIRST one we saw
			if item == null and first_empty == Vector2(-1, -1):
				first_empty = Vector2(r, c)
				
	return first_empty
