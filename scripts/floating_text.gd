## A short world-space message that rises and fades: damage numbers, pickups, alerts.
class_name FloatingText
extends Label

const SCENE_PATH := "res://scenes/floating_text.tscn"

@export var rise := 10.0
@export var time := 0.9


static func spawn(parent: Node, at: Vector2, message: String, color := Color.WHITE) -> void:
	var label: FloatingText = load(SCENE_PATH).instantiate()
	label.text = message
	label.self_modulate = color
	# drawn like the elder's bubble: UI-sized whatever the camera zoom
	label.scale = Vector2.ONE * DevSettings.values["ui_scale"] / DevSettings.values["camera_zoom"]
	label.position = at - Vector2(label.size.x / 2, 8) * label.scale
	parent.add_child(label)


func _ready() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y - rise, time)
	tween.tween_property(self, "modulate:a", 0.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(queue_free)
