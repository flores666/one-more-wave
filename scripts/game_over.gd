## Shown when Athena falls: how far the run got, and a way to start another.
extends Control

var _run: Run

@onready var _summary: Label = $Center/Panel/Box/Summary


func setup(run: Run) -> void:
	_run = run
	run.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(run.phase)


func _on_phase_changed(phase: Run.Phase) -> void:
	visible = phase == Run.Phase.DEFEAT
	_summary.text = "Held until wave %d with %d modifiers\nLoot x%.2f, %d gold" % [
		_run.wave, _run.modifiers.size(), _run.loot_multiplier(), _run.gold]


func _on_new_run_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/class_select.tscn")
