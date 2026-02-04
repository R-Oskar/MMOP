extends CharacterBody3D

@onready var head: Node = get_node("Head")
@onready var interact_ray = head.get_node("Camera3D/InteractRay")
var mouse_captured : bool = false

var place_reach = 2.7
var item_use_cooldown := 0.0
var item_use_delay := 0.15

var input_enabled: bool = true

#attributes
#Leben
const health_max : float = 100
var health: float = health_max

func check_interaction():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		
		# Check if the object we hit has the toggle_chest function
		if collider.has_method("toggle_chest"):
			collider.toggle_chest()

func _input(event):
	if event.is_action_pressed("interact"): # Create "interact" in Input Map (e.g., 'E' key)
		check_interaction()

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

#region placing blocks
## Calculates the position of where to spawn the block the player wants to place.
func calculate_block_spawn_pos() -> Vector3:
	if interact_ray.is_colliding():
		var hit_pos = interact_ray.get_collision_point()
		var hit_normal = interact_ray.get_collision_normal()
		
		# Nudge into empty space
		var spawn_pos = hit_pos + (hit_normal * 0.5)
		
		return Vector3(floor(spawn_pos.x), floor(spawn_pos.y), floor(spawn_pos.z))
	
	# Fallback if looking at nothing
	var look_dir = -head.global_transform.basis.z.normalized()
	var fallback_pos = head.global_transform.origin + look_dir * place_reach
	return fallback_pos.snapped(Vector3.ONE)

## Returns true if the block has a supporting block beneath it or is on the ground.
func block_placeable(spawn_pos: Vector3, blocks_root: Node3D = null) -> bool:
	# 1. Prevent placing below or at ground level
	if spawn_pos.y <= 0:
		return false

	# 2. If blocks_root is null, we can't check neighbors, so we assume strictly false 
	# unless you want "creative mode" behavior. For strict survival, return false here.
	if blocks_root == null:
		return false 

	var has_support = false
	# If it's on the first layer (y=1), it's supported by the floor.
	if spawn_pos.y == 1:
		has_support = true

	for child in blocks_root.get_children():
		# 3. Check if a block ALREADY exists at this exact position (Prevent overlap)
		if child.global_position.is_equal_approx(spawn_pos):
			return false
		
		# 4. Check if there is a block directly UNDERNEATH (y - 1)
		if child.global_position.is_equal_approx(spawn_pos + Vector3.DOWN):
			has_support = true

	return has_support

## Returns the blocks_root node
func get_blocks_root(create_if_missing := false) -> Node3D:
	var blocks_root := get_tree().current_scene.get_node_or_null(
		"NavigationRegion3D/World_flexible/Blocks"
	) as Node3D
	
	if blocks_root == null and create_if_missing:
		var parent := get_tree().current_scene.get_node(
			"NavigationRegion3D/World_flexible"
		) as Node3D
		
		blocks_root = Node3D.new()
		blocks_root.name = "Blocks"
		parent.add_child(blocks_root)

	return blocks_root

## Places (if possible) item/block in direction of looking.
func place_block(item) -> bool:
	var spawn_pos = calculate_block_spawn_pos()
	var blocks_root = get_blocks_root(true)

	if not block_placeable(spawn_pos, blocks_root):
		return false
	
	play_sound(item.sound)
	var instance = item.scene.instantiate()
	blocks_root.add_child(instance)
	instance.global_transform.origin = spawn_pos
	
	# Force update the preview immediately so it doesn't show inside the new block
	clear_preview() 
	return true

var last_preview: Node3D = null

## Clears the last preview item.
func clear_preview() -> void:
	if last_preview:
		last_preview.queue_free()
		last_preview = null

## Updates the preview hologram
func show_preview(item) -> void:
	var spawn_pos = calculate_block_spawn_pos()
	var blocks_root = get_blocks_root(false) # Don't create if missing, just get it
	
	# FIX: We now pass blocks_root to check the floating rule
	if not block_placeable(spawn_pos, blocks_root):
		clear_preview()
		return

	# If no preview exists or item changed, create a new one
	if not last_preview: # Simplified check; we usually queue_free on item switch anyway
		var instance = item.scene.instantiate() as Node3D
		get_tree().current_scene.add_child(instance)
		instance.global_transform.origin = spawn_pos

		# Apply transparency
		apply_transparency(instance)
		last_preview = instance
		
		# IMPORTANT: Add preview to raycast exceptions so we don't look at it!
		# If your raycast detects the preview, the math will glitch.
		if interact_ray:
			# We need to find the StaticBody or CollisionShape inside the preview
			# Usually easiest to just set the preview's collision layer to 0 or disable shapes
			disable_collision_recursively(instance)

	else:
		# Preview exists, just move it
		last_preview.global_transform.origin = spawn_pos
		
		# Verify name matches (in case you swapped items fast)
		if last_preview.name != item.scene.resource_name:
			# If names don't match logic (optional), you might want to rebuild
			pass

func disable_collision_recursively(node: Node):
	if node is CollisionShape3D or node is CollisionPolygon3D:
		node.disabled = true
	for child in node.get_children():
		disable_collision_recursively(child)

## Applies lower transparency to given node
func apply_transparency(node: Node, alpha: float = 0.5) -> void:
	if node is MeshInstance3D:
		var mat: StandardMaterial3D = node.get_active_material(0)
		if mat:
			mat = mat.duplicate() as StandardMaterial3D
			node.set_surface_override_material(0, mat)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.flags_transparent = true
			var color = mat.albedo_color
			color.a = alpha
			mat.albedo_color = color

	if node is CollisionShape3D:
		node.disabled = true

	for child in node.get_children():
		if child is Node3D:
			apply_transparency(child, alpha)
#endregion

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


#region damage
func take_damage(amount: int) -> void:
	health -= amount
	print("Spieler bekommt Schaden! Leben:", health)

	if health <= 0:
		call_deferred("die")

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UI/end_screen.tscn")
#endregion
