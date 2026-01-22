extends Control


# Called when the node enters the scene tree for the first time.
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
	visible = true
	get_tree().paused = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
func close_inventory():
	visible = false
	get_tree().paused = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
