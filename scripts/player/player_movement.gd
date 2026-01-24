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
	if not player.is_input_enabled():
		return
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
	# -----------------------
	# Freefly mode
	# -----------------------
	var input_dir
	if can_freefly and freeflying and player.is_input_enabled():
		# Horizontal input
		input_dir = Input.get_vector(input_left, input_right, input_forward, input_back)
		
		# Vertical input
		var vertical := 0
		if Input.is_action_pressed("jump"):
			vertical += 1
		if Input.is_action_pressed("fly_down"):
			vertical -= 1

		# Combine horizontal and vertical
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion.y = vertical

		motion *= freefly_speed * delta
		player.move_and_collide(motion)
		return  # skip rest of physics in freefly

	# Gravity
	if has_gravity and not player.is_on_floor():
		player.velocity += player.get_gravity() * delta * gravity_strength

	# Input handling
	input_dir = Vector2.ZERO
	if can_move and player.is_input_enabled():
		input_dir = Input.get_vector(input_left, input_right, input_forward, input_back)

	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Determine target velocity
	var target_velocity_x = 0.0
	var target_velocity_z = 0.0
	if move_dir:
		target_velocity_x = move_dir.x * move_speed
		target_velocity_z = move_dir.z * move_speed

	# Smooth horizontal movement (inertia applies even if input disabled)
	var smoothing = 15.0 if player.is_on_floor() else 3.0
	player.velocity.x = lerp(player.velocity.x, target_velocity_x, smoothing * delta)
	player.velocity.z = lerp(player.velocity.z, target_velocity_z, smoothing * delta)

	# Jumping (only if input enabled)
	if can_jump and player.is_input_enabled():
		if Input.is_action_pressed(input_jump) and player.is_on_floor():
			jump.pitch_scale = randf_range(0.9, 1.1)
			jump.play()
			player.velocity.y = jump_velocity

	# Sprinting (only if input enabled)
	move_speed = sprint_speed if can_sprint and Input.is_action_pressed(input_sprint) and player.is_input_enabled() else base_speed

	# Apply velocity
	player.move_and_slide()

	# Landing sounds
	if not was_on_floor and player.is_on_floor():
		landing.pitch_scale = randf_range(0.9, 1.1)
		landing.play()
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
