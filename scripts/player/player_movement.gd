extends Node

@export var player: CharacterBody3D
@onready var head: Node3D = player.get_node("Head")
@onready var collider: CollisionShape3D = player.get_node("Collider")
@onready var jump: AudioStreamPlayer = player.get_node("SoundEffects/Jump")
@onready var landing: AudioStreamPlayer = player.get_node("SoundEffects/Landing")

var can_move : bool = true
var has_gravity : bool = true
var can_jump : bool = true
var can_sprint : bool = false
var can_sneak: bool = true
var can_freefly : bool = false

@export_group("Speeds")
@export var look_speed : float = 0.002
@export var base_speed : float = 7.0
@export var jump_velocity : float = 6.0
@export var sprint_speed : float = 10.0
@export var freefly_speed : float = 25.0
@export var gravity_strength : float = 1.5

# Input actions
var input_left : String = "move_left"
var input_right : String = "move_right"
var input_forward : String = "move_up"
var input_back : String = "move_down"
var input_jump : String = "jump"
var input_sprint : String = "sprint"
var input_freefly : String = "freefly"

var was_on_floor: bool = false

var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

func _ready() -> void:
	look_rotation.y = player.rotation.y
	look_rotation.x = head.rotation.x
	player.capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		player.release_mouse()
	
	# Look around
	if player.mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		# Get horizontal input
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		
		# Get vertical input (space for up, optionally shift for down)
		var vertical := 0
		if Input.is_action_pressed("jump"):  # assuming "jump" is space
			vertical += 1
		if Input.is_action_pressed("fly_down"):  # optional, e.g., shift
			vertical -= 1
		
		# Combine horizontal and vertical movement
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion.y = vertical  # set vertical component
		
		# Scale by speed and delta
		motion *= freefly_speed * delta
		
		player.move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not player.is_on_floor():
			player.velocity += player.get_gravity() * delta * gravity_strength

	# Apply jumping
	if can_jump:
		if Input.is_action_pressed(input_jump) and player.is_on_floor():
			jump.pitch_scale = randf_range(0.9, 1.1)
			jump.play()
			player.velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			player.velocity.x = move_dir.x * move_speed
			player.velocity.z = move_dir.z * move_speed
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, move_speed)
			player.velocity.z = move_toward(player.velocity.z, 0, move_speed)
	else:
		player.velocity.x = 0
		player.velocity.y = 0
	
	# Use velocity to actually move
	player.move_and_slide()
	
	if not was_on_floor and player.is_on_floor():
		# Just landed
		landing.pitch_scale = randf_range(0.9, 1.1)  # optional randomness
		landing.play()
	# Update the state for next frame
	was_on_floor = player.is_on_floor()
	
## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-90), deg_to_rad(90))
	look_rotation.y -= rot_input.x * look_speed
	player.transform.basis = Basis()
	player.rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	collider.disabled = true
	freeflying = true
	player.velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false
