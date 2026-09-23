## Top-left portrait with the player's health, mana and stamina as bars and current/max readouts.
extends PanelContainer

@export var player: Player

@onready var _health: Control = $Box/Bars/Health
@onready var _mana: Control = $Box/Bars/Mana
@onready var _stamina: Control = $Box/Bars/Stamina


func _ready() -> void:
	player.stats.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var s := player.stats
	_show(_health, ceili(s.hp), ceili(s.max_hp()))
	_show(_mana, s.mp, CharacterStats.MAX_MP)
	_show(_stamina, s.stamina, CharacterStats.MAX_STAMINA)


func _show(row: Control, value: int, max_value: int) -> void:
	var bar: ProgressBar = row.get_node("Bar")
	bar.max_value = max_value
	bar.value = value
	row.get_node("Value").text = "%d/%d" % [value, max_value]
