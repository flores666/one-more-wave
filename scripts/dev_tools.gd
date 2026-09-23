## F1 panel for tweaking DevSettings and the current character live.
extends UiLayer

## Shift-click steps character values by this much instead of one.
const BIG_STEP := 10

var _stats: CharacterStats
var _character_values: Dictionary[String, Label] = {}

@onready var _sliders := {
	"camera_zoom": $Root/Panel/Box/Grid/ZoomSlider,
	"ui_scale": $Root/Panel/Box/Grid/UiSlider,
	"font_size": $Root/Panel/Box/Grid/FontSlider,
}
@onready var _readouts := {
	"camera_zoom": $Root/Panel/Box/Grid/ZoomValue,
	"ui_scale": $Root/Panel/Box/Grid/UiValue,
	"font_size": $Root/Panel/Box/Grid/FontValue,
}
@onready var _character: Control = $Root/Panel/Box/Character
@onready var _character_grid: GridContainer = $Root/Panel/Box/Character/Grid


func _ready() -> void:
	super()
	for key in _sliders:
		var slider: HSlider = _sliders[key]
		var r: Array = DevSettings.RANGES[key]
		slider.min_value = r[0]
		slider.max_value = r[1]
		slider.step = r[2]
		slider.value_changed.connect(func(value: float) -> void: DevSettings.set_value(key, value))
	$Root/Panel/Box/Reset.pressed.connect(DevSettings.reset)
	$Root/Panel/Box/Path.text = DevSettings.path
	DevSettings.changed.connect(_refresh)
	_refresh()
	for key in ["level"] + CharacterStats.STATS:
		_add_character_row(key)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_dev_tools"):
		visible = not visible


## The player hands its stats over while it is in the world, and null when it leaves.
func edit_character(stats: CharacterStats) -> void:
	if _stats:
		_stats.changed.disconnect(_refresh_character)
	_stats = stats
	_character.visible = stats != null
	if stats:
		stats.changed.connect(_refresh_character)
		_refresh_character()


func _refresh() -> void:
	for key in _sliders:
		_sliders[key].set_value_no_signal(DevSettings.values[key])
		_readouts[key].text = str(DevSettings.values[key])


func _add_character_row(key: String) -> void:
	var name_label := Label.new()
	name_label.text = "Lv" if key == "level" else key.to_upper()
	var value := Label.new()
	value.custom_minimum_size.x = 12
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_values[key] = value
	for control: Control in [name_label, _step_button("-", key, -1), value, _step_button("+", key, 1)]:
		_character_grid.add_child(control)


func _step_button(text: String, key: String, direction: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_step(key, direction * (BIG_STEP if Input.is_key_pressed(KEY_SHIFT) else 1)))
	return button


func _step(key: String, amount: int) -> void:
	if key == "level":
		_stats.set_level(_stats.level + amount)
	else:
		_stats.set_stat(key, _stats.get_stat(key) + amount)


func _refresh_character() -> void:
	for key in _character_values:
		_character_values[key].text = str(_stats.level if key == "level" else _stats.get_stat(key))
