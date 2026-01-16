extends Node

@export var place: AudioStreamPlayer

@export var input_reset : String = "reset"
@export var player: Node3D       # Drag your player node here in the editor

@export var cube_scene: PackedScene  # Drag your Cube.tscn here in the editor
@export var spawn_distance: float = 3.0  # How far in front of the player

@export var spawn_cooldown: float = 0.15  # seconds between spawns

var spawn_timer: float = 0.0

var spawn_position: Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_position = player.global_transform.origin

func _process(delta: float) -> void:
	# Reduce the cooldown timer every frame
	if spawn_timer > 0:
		spawn_timer -= delta

func _unhandled_input(_event: InputEvent) -> void:
	var y_coord = player.global_transform.origin.y
	if y_coord < -20:
		player.teleport_to_spawn()

func spawn_cube():
	if not cube_scene:
		return
	spawn_timer = spawn_cooldown  # reset cooldown

	var cube_instance = cube_scene.instantiate()
	get_tree().current_scene.add_child(cube_instance)

	# Use head/camera position for the middle-of-screen spawn
	var look_dir = -player.head.global_transform.basis.z.normalized()
	var spawn_pos = player.head.global_transform.origin + look_dir * spawn_distance
	cube_instance.global_transform.origin = spawn_pos
