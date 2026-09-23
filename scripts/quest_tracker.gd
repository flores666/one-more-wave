## Top-right quest log: the active quests with their progress and rewards.
extends PanelContainer

@export var todo_icon: Texture2D

var _quests: QuestLog
@onready var _box: VBoxContainer = $Box
@onready var _title: Label = $Box/Title


func setup(quests: QuestLog) -> void:
	_quests = quests
	quests.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _box.get_children():
		if child != _title:
			child.queue_free()
	for quest in _quests.quests:
		var box := TextureRect.new()
		box.texture = todo_icon
		box.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		box.mouse_filter = MOUSE_FILTER_IGNORE
		var label := Label.new()
		label.text = quest.text()
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 3)
		row.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_child(box)
		row.add_child(label)
		_box.add_child(row)
		var reward := Label.new()
		reward.text = "   > " + quest.reward_text()
		reward.theme_type_variation = &"HintLabel"
		_box.add_child(reward)
