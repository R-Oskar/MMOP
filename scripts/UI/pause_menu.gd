extends Control

@export var player: CharacterBody3D

func _ready():
	$AnimationPlayer.play("RESET")
	hide()

func _unhandled_input(_event: InputEvent) -> void:
	if not player.is_input_enabled():
		return
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()
	
	player.capture_mouse()

func pause():
	player.release_mouse()
	get_tree().paused = true
	show()
	$AnimationPlayer.play("blur")
