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
	visible = true
	player.toggle_input(false)
	
func close_inventory():
	hotbar.show()
	visible = false
	player.toggle_input(true)
