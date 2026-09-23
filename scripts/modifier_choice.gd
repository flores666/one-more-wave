## The cards shown after a cleared wave: pick one of the offered enemy modifiers (click or 1-3).
## The game is paused meanwhile, so this overlay keeps processing.
extends Control

const CARD_SIZE := Vector2(116, 84)

var _run: Run
var _title := Label.new()
var _cards := HBoxContainer.new()


func setup(run: Run) -> void:
	_run = run
	process_mode = PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.06, 0.1, 0.6)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	center.add_child(box)
	_title.theme_type_variation = &"TitleLabel"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	var hint := Label.new()
	hint.text = "Make the world harder. Every curse is permanent and raises the loot."
	hint.theme_type_variation = &"HintLabel"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)
	_cards.add_theme_constant_override("separation", 6)
	_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_cards)
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
		_cards.add_child(_card(i, _run.choices[i]))


func _card(index: int, modifier: EnemyModifier) -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.focus_mode = FOCUS_NONE
	card.pressed.connect(_run.choose.bind(index))
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.mouse_filter = MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 5)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.mouse_filter = MOUSE_FILTER_IGNORE
	margin.add_child(box)
	var title := Label.new()
	var owned := _run.stacks(modifier)
	title.text = "%d. %s" % [index + 1, modifier.title] + (" (x%d)" % owned if owned > 0 else "")
	title.theme_type_variation = &"TitleLabel"
	var text := Label.new()
	text.text = modifier.description
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_vertical = SIZE_EXPAND_FILL
	var loot := Label.new()
	loot.text = "+%d%% loot" % roundi(modifier.loot_bonus * 100)
	loot.theme_type_variation = &"GoldLabel"
	for label: Label in [title, text, loot]:
		label.mouse_filter = MOUSE_FILTER_IGNORE
		box.add_child(label)
	return card


func _unhandled_input(event: InputEvent) -> void:
	if not visible or event is not InputEventKey or not event.pressed or event.echo:
		return
	var index: int = [KEY_1, KEY_2, KEY_3].find(event.physical_keycode)
	if index >= 0 and index < _run.choices.size():
		get_viewport().set_input_as_handled()
		_run.choose(index)
