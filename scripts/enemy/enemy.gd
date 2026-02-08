extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var damage_area: Area3D = $Damage_Area
@onready var player = get_tree().get_first_node_in_group("player")

@export var speed := 3.0
@export var damage := 10
@export var gravity := 9.8
@export var damage_interval := 1.0
var damage_timer := 0.0
var bodies_in_damage_area: Array[Node3D] = []
var player_can_take_damage = true


func _physics_process(delta):
	apply_gravity(delta)
	update_movement()
	handle_damage()
	move_and_slide()
	
	if damage_timer >= 0:
		damage_timer -= delta


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


func handle_damage() -> void:
	if damage_timer > 0:
		return
	for body in bodies_in_damage_area:
			if body != null and body.has_method("take_damage"):
				body.take_damage(damage)
				damage_timer = damage_interval



# This function will be called from the Main scene.
func initialize(start_position, player_position):
	look_at_from_position(start_position, player_position)


func _on_body_entered(body):
	if body is PhysicsBody3D:
		bodies_in_damage_area.append(body)


func _on_body_exited(body):
	if body is PhysicsBody3D:
		bodies_in_damage_area.erase(body)
