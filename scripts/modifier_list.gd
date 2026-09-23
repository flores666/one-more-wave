## Left-side list of the enemy modifiers picked so far and the loot multiplier they add up to.
extends PanelContainer

var _run: Run
var _box := VBoxContainer.new()
var _loot := Label.new()
var _bonus := Label.new()


func setup(run: Run) -> void:
	_run = run
	_box.add_theme_constant_override("separation", 0)
	_box.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_box)
	_loot.theme_type_variation = &"GoldLabel"
	_bonus.theme_type_variation = &"GoldLabel"
	run.modifiers_changed.connect(_rebuild)
	_rebuild()


func _process(_delta: float) -> void:
	if _run == null:
		return
	_loot.text = "LOOT x%.2f" % _run.loot_multiplier()
	_bonus.visible = _run.bonus_loot() > 0.0
	_bonus.text = "quest bonus +%d%% %ds" % [roundi(_run.bonus_loot() * 100), ceili(_run.bonus_loot_time())]


func _rebuild() -> void:
	for child in _box.get_children():
		_box.remove_child(child)
		if child not in [_loot, _bonus]:
			child.queue_free()
	_box.add_child(_loot)
	_box.add_child(_bonus)
	var seen: Array[EnemyModifier] = []
	for modifier in _run.modifiers:
		if modifier in seen:
			continue
		seen.append(modifier)
		var row := Label.new()
		var count := _run.stacks(modifier)
		row.text = modifier.title + (" x%d" % count if count > 1 else "")
		row.tooltip_text = modifier.description
		_box.add_child(row)
	if seen.is_empty():
		var none := Label.new()
		none.text = "No modifiers yet"
		none.theme_type_variation = &"HintLabel"
		_box.add_child(none)
