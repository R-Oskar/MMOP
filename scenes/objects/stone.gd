extends HealthEntity

@export var block_type := "Stone"

func die():
	print(block_type, "Block zerstört")
	queue_free()
