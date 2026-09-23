## Experience bar along the bottom edge of the screen, notched like an MMO's, with the progress to
## the next level written across it.
extends ProgressBar

@export var player: Player

@onready var _text: Label = $Text


func _ready() -> void:
	player.stats.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var s := player.stats
	var maxed := s.level >= CharacterStats.MAX_LEVEL
	max_value = 1 if maxed else s.exp_to_next_level()
	value = max_value if maxed else s.experience
	_text.text = "MAX LEVEL" if maxed else "XP %d / %d" % [s.experience, s.exp_to_next_level()]
