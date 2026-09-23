## Bottom-centre hotbar. The first slot holds the class's attack; the rest are empty for now.
extends PanelContainer

const SLOTS := 4

@export var player: Player


func _ready() -> void:
	for i in SLOTS:
		var slot := PanelContainer.new()
		slot.theme_type_variation = &"SlotSelected" if i == 0 else &"Slot"
		slot.mouse_filter = MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(12, 12)
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		if i == 0:
			icon.texture = player.player_class.icon
		slot.add_child(icon)
		var key := Label.new()
		key.text = str(i + 1)
		key.theme_type_variation = &"HintLabel"
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		cell.mouse_filter = MOUSE_FILTER_IGNORE
		cell.add_child(slot)
		cell.add_child(key)
		$Row.add_child(cell)
