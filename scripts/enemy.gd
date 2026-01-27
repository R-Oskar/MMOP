extends CharacterBody3D

@export var speed := 3.0
@export var damage := 10
@export var gravity := 9.8

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	$Damage_Area.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	apply_gravity(delta)
	update_movement()

	move_and_slide()

# -------------------------
# Gravitation
# -------------------------
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

# -------------------------
# Bewegung / Pathfinding
# -------------------------
func update_movement() -> void:
	if player == null:
		velocity.x = 0
		velocity.z = 0
		return

	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return

	var next_pos = agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

# -------------------------
# Schaden
# -------------------------
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
