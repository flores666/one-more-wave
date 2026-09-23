## The cards shown after a cleared wave: pick one of the offered enemy modifiers (click or 1, 2, 3...).
## The game is paused meanwhile, so this overlay keeps processing.
extends Control

@export var card_scene: PackedScene

var _run: Run

@onready var _title: Label = $Center/Box/Title
@onready var _cards: HBoxContainer = $Center/Box/Cards


func setup(run: Run) -> void:
	_run = run
	run.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(run.phase)


func _on_phase_changed(phase: Run.Phase) -> void:
	visible = phase == Run.Phase.MODIFIER_SELECTION
	if not visible:
		return
	_title.text = "WAVE %d CLEARED" % (_run.wave - 1)
	for child in _cards.get_children():
		child.queue_free()
	for i in _run.choices.size():
		var card: Button = card_scene.instantiate()
		_cards.add_child(card)
		card.show_modifier(i + 1, _run.choices[i], _run.stacks(_run.choices[i]))
		card.pressed.connect(_run.choose.bind(i))


func _unhandled_input(event: InputEvent) -> void:
	if not visible or event is not InputEventKey or not event.pressed or event.echo:
		return
	var index: int = event.physical_keycode - KEY_1
	if index >= 0 and index < _run.choices.size():
		get_viewport().set_input_as_handled()
		_run.choose(index)
