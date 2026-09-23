## Screen-edge arrows: towards Athena whenever she is off screen (red while she is being hit), and
## towards where invaders are coming from while an invasion is on.
extends Control

@export var arrow_scene: PackedScene
@export var invader_color := Color(1, 0.4, 0.35)
@export var margin := 10.0
@export var hit_flash := 1.0
@export var blink_period := 0.4

var _run: Run
var _athena: Athena
var _invasion: InvasionDirector
var _last_hp := 0.0
var _hit := 0.0

@onready var _athena_arrow: Node2D = $AthenaArrow
@onready var _mark: Node2D = $AthenaArrow/Mark
@onready var _invader_arrows: Node2D = $InvaderArrows


func setup(run: Run, athena: Athena, invasion: InvasionDirector) -> void:
	_run = run
	_athena = athena
	_invasion = invasion
	_last_hp = run.base_hp


func _process(delta: float) -> void:
	if _run == null:
		return
	_hit = hit_flash if _run.base_hp < _last_hp else maxf(_hit - delta, 0.0)
	_last_hp = _run.base_hp
	var blink := fmod(Time.get_ticks_msec() / 1000.0, blink_period) > blink_period / 2
	_athena_arrow.modulate = _athena.hit_color if _hit > 0.0 and blink else _athena.color
	_point(_athena_arrow, _athena.global_position)
	# the diamond under the arrow stays upright
	_mark.global_rotation = 0.0
	var entries: Array[Vector2] = []
	if _run.phase == Run.Phase.INVASION:
		entries = _invasion.entries()
	while _invader_arrows.get_child_count() < entries.size():
		var arrow: Node2D = arrow_scene.instantiate()
		arrow.modulate = invader_color
		_invader_arrows.add_child(arrow)
	for i in _invader_arrows.get_child_count():
		var arrow: Node2D = _invader_arrows.get_child(i)
		arrow.visible = false
		if i < entries.size():
			_point(arrow, entries[i])


## Puts the arrow on the screen edge pointing at a world position, or hides it while that position
## is on screen.
func _point(arrow: Node2D, world: Vector2) -> void:
	# world -> viewport pixels -> this control's own coordinates (its layer carries the UI scale)
	var at: Vector2 = get_global_transform_with_canvas().affine_inverse() * (get_viewport().get_canvas_transform() * world)
	var rect := Rect2(Vector2.ZERO, size).grow(-margin)
	arrow.visible = not rect.has_point(at)
	if not arrow.visible:
		return
	var center := rect.get_center()
	var dir := (at - center).normalized()
	# walk from the centre to the rectangle's edge along dir
	var scale_x := (rect.size.x / 2) / absf(dir.x) if dir.x != 0.0 else INF
	var scale_y := (rect.size.y / 2) / absf(dir.y) if dir.y != 0.0 else INF
	arrow.position = center + dir * minf(scale_x, scale_y)
	arrow.rotation = dir.angle()
