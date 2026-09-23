## Screen-space UI scaled by the "UI scale" dev setting. Content lives under a "Root"
## control sized to the scaled-down viewport, so anchored elements stay on screen.
class_name UiLayer
extends CanvasLayer


func _ready() -> void:
	DevSettings.changed.connect(_apply_ui_scale)
	get_viewport().size_changed.connect(_apply_ui_scale)
	_apply_ui_scale()


func _apply_ui_scale() -> void:
	var ui_scale: float = DevSettings.values["ui_scale"]
	scale = Vector2.ONE * ui_scale
	var root: Control = $Root
	root.position = Vector2.ZERO
	root.size = get_viewport().get_visible_rect().size / ui_scale
