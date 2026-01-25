extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const damage = 500


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player dedectet")
		body.take_damage(damage)
	
