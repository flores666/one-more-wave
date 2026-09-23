## Bottom-centre hotbar. The first slot holds the class's attack; the rest are empty for now.
extends PanelContainer

@export var player: Player

@onready var _attack_icon: TextureRect = $Row/Slot1/Frame/Icon


func _ready() -> void:
	_attack_icon.texture = player.player_class.icon
