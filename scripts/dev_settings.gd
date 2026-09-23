## Developer display settings. Loaded from JSON on every start, saved on every change.
extends Node

signal changed

const DEFAULTS := {"camera_zoom": 1.0, "ui_scale": 0.5, "font_size": 8}
## [min, max, step] per setting; values from the file are clamped and snapped to these.
## Font size moves in whole multiples of the 8px bitmap font. UI scale moves in halves: the
## 4x integer window stretch turns each half step into whole screen pixels, so pixel UI stays crisp.
const RANGES := {"camera_zoom": [0.5, 4.0, 0.25], "ui_scale": [0.5, 3.0, 0.5], "font_size": [8, 24, 8]}

## Inside the project while developing, so the file can be committed; user data in exported builds.
var path := "res://dev_settings.json" if OS.has_feature("editor") else "user://dev_settings.json"
var values := DEFAULTS.duplicate()


func _ready() -> void:
	_load()
	_apply_font_size()


func set_value(key: String, value: float) -> void:
	values[key] = _sanitize(key, value)
	if key == "font_size":
		_apply_font_size()
	_save()
	changed.emit()


func reset() -> void:
	values = DEFAULTS.duplicate()
	_apply_font_size()
	_save()
	changed.emit()


func _sanitize(key: String, value: float) -> Variant:
	var r: Array = RANGES[key]
	var v := snappedf(clampf(value, r[0], r[1]), r[2])
	return int(v) if DEFAULTS[key] is int else v


func _apply_font_size() -> void:
	# Every Control uses the project theme, so this one value sizes all text.
	ThemeDB.get_project_theme().default_font_size = values["font_size"]


func _load() -> void:
	if not FileAccess.file_exists(path):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if data is not Dictionary:
		push_warning("Ignoring unreadable dev settings in %s" % path)
		return
	for key in DEFAULTS:
		if typeof(data.get(key)) in [TYPE_INT, TYPE_FLOAT]:
			values[key] = _sanitize(key, data[key])


func _save() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot save dev settings to %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(values, "\t"))
