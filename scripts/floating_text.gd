## A short world-space message that rises and fades: damage numbers, pickups, alerts.
class_name FloatingText
extends Label

const WIDTH := 120.0
const RISE := 10.0
const TIME := 0.9


static func spawn(parent: Node, at: Vector2, message: String, color := Color.WHITE) -> void:
	var label := FloatingText.new()
	label.text = message
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.z_index = 10
	label.size = Vector2(WIDTH, 0)
	# drawn like the elder's bubble: UI-sized whatever the camera zoom
	label.scale = Vector2.ONE * DevSettings.values["ui_scale"] / DevSettings.values["camera_zoom"]
	label.position = at - Vector2(WIDTH / 2, 8) * label.scale
	parent.add_child(label)
	var tween := label.create_tween().set_parallel()
	tween.tween_property(label, "position:y", label.position.y - RISE, TIME)
	tween.tween_property(label, "modulate:a", 0.0, TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(label.queue_free)
