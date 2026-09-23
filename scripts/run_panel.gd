## Top-centre readout of the loop: wave, phase, time to the invasion or invaders left, Athena's health.
extends PanelContainer

const FARMING_COLOR := Color(0.55, 0.85, 0.45)
const DANGER_COLOR := Color(1, 0.4, 0.35)
const CALM_COLOR := Color(1, 0.82, 0.25)
## The countdown turns red and blinks this close to the invasion.
const WARN_TIME := 15.0

var _run: Run
var _invasion: InvasionDirector
var _wave := Label.new()
var _phase := Label.new()
var _bar := ProgressBar.new()
var _hp := Label.new()


func setup(run: Run, invasion: InvasionDirector) -> void:
	_run = run
	_invasion = invasion
	# keeps reading the run while modifier selection pauses the game
	process_mode = PROCESS_MODE_ALWAYS
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	_wave.theme_type_variation = &"TitleLabel"
	top.add_child(_wave)
	top.add_child(_phase)
	box.add_child(top)
	var base := HBoxContainer.new()
	base.add_theme_constant_override("separation", 3)
	var name_label := Label.new()
	name_label.text = "ATHENA"
	name_label.theme_type_variation = &"HintLabel"
	base.add_child(name_label)
	_bar.theme_type_variation = &"HealthBar"
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(60, 5)
	_bar.size_flags_vertical = SIZE_SHRINK_CENTER
	_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	base.add_child(_bar)
	_hp.custom_minimum_size.x = 36
	_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	base.add_child(_hp)
	box.add_child(base)
	add_child(box)
	for control: Control in [box, top, base, name_label, _bar, _hp, _wave, _phase]:
		control.mouse_filter = MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if _run == null:
		return
	_wave.text = "WAVE %d" % _run.wave
	var color := CALM_COLOR
	match _run.phase:
		Run.Phase.FARMING:
			var t := ceili(_run.time_left)
			_phase.text = "FARMING  invasion in %d:%02d" % [t / 60, t % 60]
			color = FARMING_COLOR
			if _run.time_left < WARN_TIME:
				color = DANGER_COLOR if fmod(_run.time_left, 0.5) > 0.25 else CALM_COLOR
		Run.Phase.INVASION:
			_phase.text = "INVASION  %d left" % _invasion.remaining()
			color = DANGER_COLOR
		Run.Phase.WAVE_COMPLETED:
			_phase.text = "WAVE CLEARED"
		Run.Phase.MODIFIER_SELECTION:
			_phase.text = "CHOOSE A MODIFIER"
		Run.Phase.DEFEAT:
			_phase.text = "DEFEAT"
			color = DANGER_COLOR
	_phase.add_theme_color_override("font_color", color)
	_bar.max_value = _run.config.base_max_hp
	_bar.value = _run.base_hp
	_hp.text = "%d/%d" % [ceili(_run.base_hp), _run.config.base_max_hp]
