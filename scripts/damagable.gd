extends Node
class_name HealthEntity

@export var max_health: int = 10
var health: int

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	print(name, " nimmt Schaden:", amount, " Leben:", health)

	if health <= 0:
		die()

func die() -> void:
	queue_free()
