extends Node3D

@export var node: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector3(1, 2, 3)
	node.position = Vector(1, 2, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
