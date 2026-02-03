extends Node
class_name Damageable

@export var max_health := 100.0
@onready var health := max_health 

func take_damage(damage:float) -> void: 
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()
