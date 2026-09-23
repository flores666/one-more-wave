## Top-left portrait with the player's level badge, and health, mana and stamina as bars and
## current/max readouts.
extends PanelContainer

@export var player: Player
@export var level_up_color := Color.WHITE
@export var level_up_flash := 0.8

var _flash_tween: Tween

@onready var _level: Label = $Box/Portrait/Level
@onready var _level_color := _level.get_theme_color("font_color")
@onready var _health: Control = $Box/Bars/Health
@onready var _mana: Control = $Box/Bars/Mana
@onready var _stamina: Control = $Box/Bars/Stamina


func _ready() -> void:
	player.stats.changed.connect(_refresh)
	player.stats.leveled_up.connect(_flash)
	_refresh()


func _refresh() -> void:
	var s := player.stats
	_level.text = str(s.level)
	_show(_health, ceili(s.hp), ceili(s.max_hp()))
	_show(_mana, s.mp, CharacterStats.MAX_MP)
	_show(_stamina, s.stamina, CharacterStats.MAX_STAMINA)


func _show(row: Control, value: int, max_value: int) -> void:
	var bar: ProgressBar = row.get_node("Bar")
	bar.max_value = max_value
	bar.value = value
	row.get_node("Value").text = "%d/%d" % [value, max_value]


func _flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_level.add_theme_color_override("font_color", level_up_color)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_level, "theme_override_colors/font_color", _level_color, level_up_flash)
