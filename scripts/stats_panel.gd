## HUD readout of the player's level, experience, primary stats and the combat numbers they give.
extends PanelContainer

const LEVEL_UP_COLOR := Color(1, 0.82, 0.25)
const LEVEL_UP_FLASH := 0.8

@export var player: Player

var _values: Dictionary[String, Label] = {}
var _flash_tween: Tween

@onready var _title: Label = $Box/Header/Title
@onready var _exp: Label = $Box/Header/Exp
@onready var _bar: ProgressBar = $Box/ExpBar
@onready var _grid: GridContainer = $Box/Grid
@onready var _title_color := _title.get_theme_color("font_color")


func _ready() -> void:
	for key in _readouts():
		var name_label := Label.new()
		name_label.text = key
		# the stat that scales this class's damage stands out
		name_label.theme_type_variation = &"TitleLabel" if key.to_lower() == player.player_class.main_stat else &"HintLabel"
		var value := Label.new()
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_grid.add_child(name_label)
		_grid.add_child(value)
		_values[key] = value
	player.stats.changed.connect(_refresh)
	player.stats.leveled_up.connect(_flash)
	_refresh()


func _readouts() -> Dictionary[String, String]:
	var s := player.stats
	return {
		"STR": str(s.get_stat("str")),
		"AGI": str(s.get_stat("agi")),
		"INT": str(s.get_stat("int")),
		"LUK": str(s.get_stat("luk")),
		"DMG": "%.1f" % s.damage(),
		"APS": "%.2f" % (1.0 / s.cooldown()),
		"CRIT": "%d%%" % roundi(s.crit_chance() * 100),
		"CDMG": "%d%%" % roundi(s.crit_multiplier() * 100),
		"MOVE": "%d%%" % roundi(s.move_speed() * 100),
	}


func _refresh() -> void:
	var s := player.stats
	_title.text = "Lv %d %s" % [s.level, s.player_class.display_name]
	var maxed := s.level >= CharacterStats.MAX_LEVEL
	_exp.text = "MAX" if maxed else "%d/%d" % [s.experience, s.exp_to_next_level()]
	_bar.max_value = 1 if maxed else s.exp_to_next_level()
	_bar.value = 1 if maxed else s.experience
	var readouts := _readouts()
	for key in readouts:
		_values[key].text = readouts[key]


func _flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_title.add_theme_color_override("font_color", LEVEL_UP_COLOR)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_title, "theme_override_colors/font_color", _title_color, LEVEL_UP_FLASH)
