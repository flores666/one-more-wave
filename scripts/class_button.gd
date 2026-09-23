## A class-select button: shows its class's name and starts a run as that class.
class_name ClassButton
extends Button

@export var player_class: PlayerClass


func _ready() -> void:
	text = player_class.display_name
