extends StaticBody3D

@onready var lid_hinge: Node3D = $LidHinge

var is_open: bool = false

@export var chest_items: Array[Item] = [null,null,null,null, null,null,null,null,null,null]

# Configuration
@export var open_angle: float = 110.0 # Degrees to swing back
@export var toggle_speed: float = 0.8  # Seconds the animation takes
@export var inventory: Control

func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel")):
		toggle_chest()

## ChatGPT Code
func toggle_chest():
	is_open = !is_open
	
	# 1. Create the tween
	var tween = create_tween()
	
	# 2. Determine the target rotation
	var target_rot = open_angle if is_open else 0.0
	
	# 3. Animate! 
	# We use rotation_degrees because it's easier to reason with than radians.
	tween.tween_property(lid_hinge, "rotation_degrees:x", target_rot, toggle_speed)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	if is_open:
		open_chest()
	else:
		close_chest()

func open_chest() -> void:
	inventory.open_chest(self)

func close_chest() -> void:
	inventory.close_chest(self)

func update(new_chest_items) -> void:
	for i in chest_items.size():
		chest_items[i] = new_chest_items[i]
