extends VBoxContainer

@export var inventory:Control
@export var crafting_sound: AudioStreamPlayer

func _ready():
	# Iterate through all children of this node
	for child in get_children():
		if child is Button:
			# Connect the signal and "bind" the child node itself as an argument
			child.pressed.connect(_on_button_pressed.bind(child))

func _on_button_pressed(button: Button):
	var recipe = button.recipe
	
	# Assuming keys[0] is ingredient and keys[1] is the result based on your snippet
	var ingredient_id = recipe.ingredients.keys()[0]
	var required_amount = recipe.ingredients[ingredient_id]
	var result_id = recipe.result_item
	
	# 1. Check if we have enough
	var locations = inventory.inventory_contains(ingredient_id)
	var total = inventory.get_total_from_locations(locations)
	
	if total < required_amount:
		print("Not enough ingredients!")
		return

	# 2. Consume the items
	var remaining_to_consume = required_amount
	crafting_sound.play()
	
	for coords in locations.keys():
		if remaining_to_consume <= 0:
			break
			
		var row = int(coords.x)
		var col = int(coords.y)
		var amount_in_slot = locations[coords]
		
		if amount_in_slot <= remaining_to_consume:
			# This stack is smaller than or equal to what we need, delete it
			remaining_to_consume -= amount_in_slot
			inventory.clear_inventory_slot(row, col)
		else:
			# This stack has more than we need, just reduce the count
			inventory.change_count(-remaining_to_consume, row, col)
			remaining_to_consume = 0

	# 3. Give the result item
	# You might want to find an empty slot or a stackable slot. 
	# For now, let's put it in the first available space or row 0.
	inventory.load_item_to_inventory(result_id, 0, 0, 1) 
	
	# Refresh the UI for the crafting table if needed
	button.update_current_amount()
	
