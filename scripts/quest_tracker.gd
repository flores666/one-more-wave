## Top-right quest log: the active quests with their progress and rewards.
extends PanelContainer

@export var row_scene: PackedScene

var _quests: QuestLog

@onready var _rows: VBoxContainer = $Box/Rows


func setup(quests: QuestLog) -> void:
	_quests = quests
	quests.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _rows.get_children():
		child.queue_free()
	for quest in _quests.quests:
		var row: Control = row_scene.instantiate()
		_rows.add_child(row)
		row.show_quest(quest)
