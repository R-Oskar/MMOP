extends Control

@export var player:CharacterBody3D
@export var hotbar: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_inventory()

func _input(event):
	if event.is_action_pressed("inventory"):
		if visible:
			close_inventory()
		else:
			open_inventory()

func open_inventory():
	hotbar.hide()
	player.release_mouse()
	visible = true
	get_tree().paused = true
	
func close_inventory():
	hotbar.show()
	player.capture_mouse()
	visible = false
	get_tree().paused = false
