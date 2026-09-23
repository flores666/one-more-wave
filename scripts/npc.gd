## The elder at Athena. While farming, talking to him twice sounds the horn and calls the invasion early.
extends StaticBody2D

@export var available_icon: Texture2D

## Bubble text wraps beyond this width (in pixels at the base 8px font size).
const BUBBLE_MAX_WIDTH := 84

var run: Run
var _player_near := false
## Set after he offers to sound the horn, so the next talk accepts.
var _horn_offered := false

@onready var _marker: Sprite2D = $Marker
@onready var _bubble: Label = $BubbleAnchor/Bubble


func _ready() -> void:
	$TalkZone.body_entered.connect(_set_near.bind(true).unbind(1))
	$TalkZone.body_exited.connect(_set_near.bind(false).unbind(1))
	DevSettings.changed.connect(_apply_bubble_scale)
	_apply_bubble_scale()
	# the quest icon bobs by one pixel
	var bob := create_tween().set_loops()
	bob.tween_property(_marker, "position:y", _marker.position.y - 1, 0.4).set_delay(0.4)
	bob.tween_property(_marker, "position:y", _marker.position.y, 0.4).set_delay(0.4)


func _unhandled_input(event: InputEvent) -> void:
	if _player_near and event.is_action_pressed("interact"):
		_say(_talk())


## The run hands itself over once it exists; the marker then follows its phases.
func setup(from: Run) -> void:
	run = from
	run.phase_changed.connect(_refresh_marker.unbind(1))
	_refresh_marker()


func _talk() -> String:
	var offered := _horn_offered
	_horn_offered = false
	match run.phase:
		Run.Phase.FARMING:
			if offered:
				run.call_invasion()
				return "To arms! Here they come!"
			_horn_offered = true
			return "The horde comes in %ds. Talk again and I'll sound the horn now." % ceili(run.time_left)
		Run.Phase.INVASION:
			return "Hold the line! Keep them off Athena!"
	return "Well fought. Rest while you can."


func _set_near(near: bool) -> void:
	_player_near = near
	_horn_offered = false
	_bubble.visible = near
	_marker.visible = not near  # the bubble takes the icon's place
	_say("[E] Talk")


## Sizes the bubble to its text, wrapping long lines, centred over the elder and growing upward.
func _say(text: String) -> void:
	_bubble.text = text
	var font_size := _bubble.get_theme_font_size("font_size")
	var style := _bubble.get_theme_stylebox("normal")
	var max_width := BUBBLE_MAX_WIDTH * font_size / 8.0
	var text_width := _bubble.get_theme_font("font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var width := ceilf(minf(text_width, max_width) + style.get_minimum_size().x)
	width += fmod(width, 2.0)  # even, so the bubble sits on whole pixels around the centre
	_bubble.offset_left = -width / 2
	_bubble.offset_right = width / 2
	# zero height: the label grows upward to fit its wrapped lines
	_bubble.offset_top = _bubble.offset_bottom


## The bubble is UI drawn in the world: cancel the camera zoom and apply the UI scale, so it
## matches the HUD's size and stays on whole screen pixels.
func _apply_bubble_scale() -> void:
	$BubbleAnchor.scale = Vector2.ONE * DevSettings.values["ui_scale"] / DevSettings.values["camera_zoom"]


## "!" while the horn can be sounded, nothing otherwise.
func _refresh_marker() -> void:
	_marker.texture = available_icon if run.phase == Run.Phase.FARMING else null
