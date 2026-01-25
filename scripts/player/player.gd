extends CharacterBody3D

@onready var head: Node = get_node("Head")
var mouse_captured : bool = false

var place_reach = 2.7
var item_use_cooldown := 0.0
var item_use_delay := 0.15

var input_enabled: bool = true

#attributes
#Leben
const health_max : float = 100
var health: float = health_max

func _process(delta) -> void:
	if item_use_cooldown > 0:
		item_use_cooldown -= delta


## Disables (if parameter is false) or enables (if parameter is true) all player input.
func enable_input(enable: bool) -> void:
	input_enabled = enable
	
	set_process(enable)
	set_physics_process(enable)
	set_process_input(enable)
	set_process_unhandled_input(enable)

	if enable:
		capture_mouse()
	else:
		release_mouse()

## Caputres the mouse so the player can look around again.
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

## Releases the mouse so the player can interact with menus.
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

## Calculates the position of where to spawn the block the player wants to place.
func calculate_block_spawn_pos() -> Vector3:
	var look_dir = -head.global_transform.basis.z.normalized()
	var spawn_pos = head.global_transform.origin + look_dir * place_reach

	# Round coordinates to nearest integer for grid system
	spawn_pos = Vector3(round(spawn_pos.x), round(spawn_pos.y), round(spawn_pos.z))
	return spawn_pos

## Returns boolean if it should be possible for the player to place a block at the given location.
func block_placeable(spawn_pos: Vector3, blocks_root: Node3D = null) -> bool:
	if spawn_pos.y <= 0:
		return false

	if blocks_root == null:
		return true # preview mode, only positional rules

	for child in blocks_root.get_children():
		if child.global_transform.origin == spawn_pos:
			return false

	return true

## Returns the blocks_root node (Node for organizing, which all player placed blocks have as a parent)
func get_blocks_root(create_if_missing := false) -> Node3D:
	var blocks_root = get_tree().current_scene.get_node_or_null("Blocks")

	if blocks_root == null and create_if_missing:
		blocks_root = Node3D.new()
		blocks_root.name = "Blocks"
		get_tree().current_scene.add_child(blocks_root)

	return blocks_root

## Places (if possible) item/block in direction of looking.
## Returns true if succesful, returns false if placing is not possible.
func place_block(item) -> bool:
	var spawn_pos = calculate_block_spawn_pos()
	var blocks_root = get_blocks_root(true)

	if not block_placeable(spawn_pos, blocks_root):
		return false
	
	play_sound(item.sound)
	var instance = item.scene.instantiate()
	blocks_root.add_child(instance)
	instance.global_transform.origin = spawn_pos
	return true

var last_preview: Node3D = null

## Clears the last preview item.
func clear_preview() -> void:
	if last_preview:
		last_preview.queue_free()
		last_preview = null

## If having a block selected in the hotbar, a less transparent version is displayed where you would currently place the block.
func show_preview(item) -> void:
	var spawn_pos = calculate_block_spawn_pos()

	if not block_placeable(spawn_pos):
		clear_preview()
		return

	# If no preview exists or item changed, create a new one
	if not last_preview or last_preview.name != item.scene.resource_name:
		clear_preview()
		var instance = item.scene.instantiate() as Node3D
		get_tree().current_scene.add_child(instance)  # add first
		instance.global_transform.origin = spawn_pos

		# Apply transparency recursively to all MeshInstances
		apply_transparency(instance)

		last_preview = instance
	else:
		# Preview exists, just move it
		last_preview.global_transform.origin = spawn_pos

## Applies lower transparency to given node with given alpha channel.
func apply_transparency(node: Node, alpha: float = 0.5) -> void:
	# Handle MeshInstance3D
	if node is MeshInstance3D:
		var mat: StandardMaterial3D = node.get_active_material(0)
		if mat:
			# Duplicate material so other instances aren't affected
			mat = mat.duplicate() as StandardMaterial3D
			node.set_surface_override_material(0, mat)

			# Enable transparency
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.flags_transparent = true

			# Adjust only alpha
			var color = mat.albedo_color
			color.a = alpha
			mat.albedo_color = color

	# Handle CollisionShape3D
	if node is CollisionShape3D:
		node.disabled = true  # disables collisions for preview

	# Recurse over children (only Node3D to skip non-spatial nodes)
	for child in node.get_children():
		if child is Node3D:
			apply_transparency(child, alpha)

## Uses item if use is not on cooldown.
func try_to_use_item(item) -> bool:
	if item_use_cooldown <= 0:
		item_use_cooldown = item_use_delay
		return use_selected_item(item)
	return false

## Places item if placable, otherwise returns false.
func use_selected_item(item) -> bool:
	if item.scene:
		return place_block(item)
	return false

func play_sound(sound) -> void:
	var music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = sound
	music_player.play()

func is_input_enabled() -> bool:
	return input_enabled

func take_damage(amount: int) -> void:
	health -= amount
	print("Spieler bekommt Schaden! Leben:", health)

	if health <= 0:
		die()	

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UI/end_screen.tscn")
