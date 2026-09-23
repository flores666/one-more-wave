## Top-centre readout of the loop: wave, phase, time to the invasion or invaders left, Athena's health.
## Keeps processing while modifier selection pauses the game.
extends PanelContainer

@export var farming_color := Color(0.55, 0.85, 0.45)
@export var danger_color := Color(1, 0.4, 0.35)
@export var calm_color := Color(1, 0.82, 0.25)
## The countdown turns red and blinks this close to the invasion.
@export var warn_time := 15.0

var _run: Run
var _invasion: InvasionDirector

@onready var _wave: Label = $Box/Top/Wave
@onready var _phase: Label = $Box/Top/Phase
@onready var _bar: ProgressBar = $Box/Base/Bar
@onready var _hp: Label = $Box/Base/Value


func setup(run: Run, invasion: InvasionDirector) -> void:
	_run = run
	_invasion = invasion


func _process(_delta: float) -> void:
	if _run == null:
		return
	_wave.text = "WAVE %d" % _run.wave
	var color := calm_color
	match _run.phase:
		Run.Phase.FARMING:
			var t := ceili(_run.time_left)
			_phase.text = "FARMING  invasion in %d:%02d" % [t / 60, t % 60]
			color = farming_color
			if _run.time_left < warn_time:
				color = danger_color if fmod(_run.time_left, 0.5) > 0.25 else calm_color
		Run.Phase.INVASION:
			_phase.text = "INVASION  %d left" % _invasion.remaining()
			color = danger_color
		Run.Phase.WAVE_COMPLETED:
			_phase.text = "WAVE CLEARED"
		Run.Phase.MODIFIER_SELECTION:
			_phase.text = "CHOOSE A MODIFIER"
		Run.Phase.DEFEAT:
			_phase.text = "DEFEAT"
			color = danger_color
	_phase.self_modulate = color
	_bar.max_value = _run.config.base_max_hp
	_bar.value = _run.base_hp
	_hp.text = "%d/%d" % [ceili(_run.base_hp), _run.config.base_max_hp]
