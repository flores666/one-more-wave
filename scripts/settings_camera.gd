extends Camera2D


func _ready() -> void:
	DevSettings.changed.connect(_apply)
	_apply()


func _apply() -> void:
	zoom = Vector2.ONE * DevSettings.values["camera_zoom"]
