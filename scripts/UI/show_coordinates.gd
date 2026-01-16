extends RichTextLabel

@export var player: Node3D  # Assign your player node in the editor

func _ready() -> void:
	bbcode_enabled = true  # Enable BBCode for coloring

func _process(_delta: float) -> void:
	if player:
		var pos = player.global_transform.origin
		text = "[color=red]x: %.2f[/color]\n[color=green]y: %.2f[/color]\n[color=blue]z: %.2f[/color]" % [pos.x, pos.y, pos.z]
