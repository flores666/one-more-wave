## F1 panel for tweaking DevSettings and the current character live.
extends UiLayer

var _stats: CharacterStats

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
@onready var _steppers: Array[Node] = $Root/Panel/Box/Character/Grid.get_children()


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
	for stepper: StatStepper in _steppers:
		stepper.stepped.connect(_step)


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


func _step(key: String, amount: int) -> void:
	if key == "level":
		_stats.set_level(_stats.level + amount)
	else:
		_stats.set_stat(key, _stats.get_stat(key) + amount)


func _refresh_character() -> void:
	for stepper: StatStepper in _steppers:
		stepper.show_value(_stats.level if stepper.key == "level" else _stats.get_stat(stepper.key))
