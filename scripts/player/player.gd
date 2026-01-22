extends CharacterBody3D

@onready var head: Node = get_node("Head")
var mouse_captured : bool = false

var place_reach = 2.7
var place_cooldown := 0.0
var place_delay := 0.15

func _process(delta):
	if place_cooldown > 0:
		place_cooldown -= delta

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func calculate_block_spawn_pos():
	var look_dir = -head.global_transform.basis.z.normalized()
	var spawn_pos = head.global_transform.origin + look_dir * place_reach

	# Round coordinates to nearest integer
	spawn_pos = Vector3(round(spawn_pos.x), round(spawn_pos.y), round(spawn_pos.z))
	return spawn_pos

func block_placeable(spawn_pos: Vector3, blocks_root: Node3D = null) -> bool:
	if spawn_pos.y <= 0:
		return false

	if blocks_root == null:
		return true # preview mode, only positional rules

	for child in blocks_root.get_children():
		if child.global_transform.origin == spawn_pos:
			return false

	return true

func get_blocks_root(create_if_missing := false) -> Node3D:
	var blocks_root = get_tree().current_scene.get_node_or_null("Blocks")

	if blocks_root == null and create_if_missing:
		blocks_root = Node3D.new()
		blocks_root.name = "Blocks"
		get_tree().current_scene.add_child(blocks_root)

	return blocks_root

func place_block(item) -> bool:
	var spawn_pos = calculate_block_spawn_pos()
	var blocks_root = get_blocks_root(true)

	if not block_placeable(spawn_pos, blocks_root):
		return false

	var instance = item.scene.instantiate()
	blocks_root.add_child(instance)
	instance.global_transform.origin = spawn_pos
	return true

var last_preview: Node3D = null

func clear_preview():
	if last_preview:
		last_preview.queue_free()
		last_preview = null

func show_preview(item):
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
		_apply_transparency(instance)

		last_preview = instance
	else:
		# Preview exists, just move it
		last_preview.global_transform.origin = spawn_pos

func _apply_transparency(node: Node, alpha: float = 0.5):
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
			_apply_transparency(child, alpha)

func try_to_use_item(item):
	if place_cooldown <= 0:
		place_cooldown = place_delay
		return use_selected_item(item)
	return false

func use_selected_item(item):
	# item only has a scene when placable(scene is being placed into world)
	if item.scene:
		return place_block(item)
	return false
