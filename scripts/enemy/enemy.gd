extends CharacterBody3D

@export var speed := 3.0
@export var damage := 10
@export var gravity := 9.8
@export var damage_interval := 0.5 # Sekunden zwischen Schaden

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var damage_area: Area3D = $Damage_Area
@onready var player = get_tree().get_first_node_in_group("player")

var player_in_damage_area := false
var damage_timer := 0.0


func _ready():
	pass


func _physics_process(delta):
	apply_gravity(delta)
	update_movement()
	handle_damage(delta)
	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0


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


func handle_damage(delta: float) -> void:
	if not player_in_damage_area:
		return

	damage_timer += delta

	if damage_timer >= damage_interval:
		if player != null and player.has_method("take_damage"):
			player.take_damage(damage)
		damage_timer = 0.0


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_damage_area = true
		handle_damage(get_physics_process_delta_time()) 


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_damage_area = false
		damage_timer = 0.0
