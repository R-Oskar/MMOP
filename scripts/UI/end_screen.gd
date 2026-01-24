extends Control

func _ready():
	get_tree().paused = true
	visible = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
