extends CharacterBody3D

@onready var head: Node = get_node("Head")
var mouse_captured : bool = false

var place_reach = 3
var place_cooldown := 0.0
var place_delay := 0.1

func _process(delta):
	if place_cooldown > 0:
		place_cooldown -= delta

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func place_block(item):
	var look_dir = -head.global_transform.basis.z.normalized()
	var spawn_pos = head.global_transform.origin + look_dir * place_reach

	# Round coordinates to nearest integer
	spawn_pos = Vector3(round(spawn_pos.x), round(spawn_pos.y), round(spawn_pos.z))

	# Check if a block already exists at this position
	var blocks_root = get_tree().current_scene.get_node("Blocks") # Node3D container for all blocks

	var can_place = true
	for child in blocks_root.get_children():
		if child.global_transform.origin == spawn_pos:
			can_place = false
			break
	if spawn_pos.y <= 0:
		can_place = false

	if can_place:
		var instance = item.scene.instantiate()
		blocks_root.add_child(instance)
		instance.global_transform.origin = spawn_pos
	return can_place

func try_to_use_item(item):
	if place_cooldown <= 0:
		use_selected_item(item)
		place_cooldown = place_delay
		return true
	return false

func use_selected_item(item):
	# item only has a scene when placable(scene is being placed into world)
	if item.scene:
		place_block(item)
