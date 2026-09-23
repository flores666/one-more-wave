## Left-side list of the enemy modifiers picked so far and the loot multiplier they add up to.
extends PanelContainer

var _run: Run

@onready var _loot: Label = $Box/Loot
@onready var _bonus: Label = $Box/Bonus
@onready var _list: Label = $Box/List
@onready var _none: Label = $Box/None


func setup(run: Run) -> void:
	_run = run
	run.modifiers_changed.connect(_refresh_list)
	_refresh_list()


func _process(_delta: float) -> void:
	if _run == null:
		return
	_loot.text = "LOOT x%.2f" % _run.loot_multiplier()
	_bonus.visible = _run.bonus_loot() > 0.0
	_bonus.text = "quest bonus +%d%% %ds" % [roundi(_run.bonus_loot() * 100), ceili(_run.bonus_loot_time())]


func _refresh_list() -> void:
	var lines: PackedStringArray = []
	var seen: Array[EnemyModifier] = []
	for modifier in _run.modifiers:
		if modifier in seen:
			continue
		seen.append(modifier)
		var count := _run.stacks(modifier)
		lines.append(modifier.title + (" x%d" % count if count > 1 else ""))
	_list.text = "\n".join(lines)
	_list.visible = not lines.is_empty()
	_none.visible = lines.is_empty()
