## Shown when Athena falls: how far the run got, and a way to start another.
extends Control

var _run: Run
var _summary := Label.new()


func setup(run: Run) -> void:
	_run = run
	process_mode = PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0.1, 0.03, 0.04, 0.7)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title := Label.new()
	title.text = "ATHENA HAS FALLEN"
	title.add_theme_color_override("font_color", Color(1, 0.4, 0.35))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_summary)
	var again := Button.new()
	again.text = "New run"
	again.pressed.connect(func() -> void:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/class_select.tscn"))
	box.add_child(again)
	run.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(run.phase)


func _on_phase_changed(phase: Run.Phase) -> void:
	visible = phase == Run.Phase.DEFEAT
	_summary.text = "Held until wave %d with %d modifiers\nLoot x%.2f, %d gold" % [
		_run.wave, _run.modifiers.size(), _run.loot_multiplier(), _run.gold]
