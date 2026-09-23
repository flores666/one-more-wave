## Screen-edge arrows: towards Athena whenever she is off screen (red while she is being hit), and
## towards where invaders are coming from while an invasion is on.
extends Control

const MARGIN := 10.0
const SIZE := 5.0
const HIT_FLASH := 1.0

var _run: Run
var _athena: Athena
var _invasion: InvasionDirector
var _last_hp := 0.0
var _hit := 0.0


func setup(run: Run, athena: Athena, invasion: InvasionDirector) -> void:
	_run = run
	_athena = athena
	_invasion = invasion
	_last_hp = run.base_hp


func _process(delta: float) -> void:
	if _run == null:
		return
	_hit = HIT_FLASH if _run.base_hp < _last_hp else maxf(_hit - delta, 0.0)
	_last_hp = _run.base_hp
	queue_redraw()


func _draw() -> void:
	if _run == null:
		return
	var blink := fmod(Time.get_ticks_msec() / 1000.0, 0.4) > 0.2
	var color := Athena.HIT_COLOR if _hit > 0.0 and blink else Athena.COLOR
	_arrow(_athena.global_position, color, true)
	if _run.phase == Run.Phase.INVASION:
		for entry in _invasion.entries():
			_arrow(entry, Color(1, 0.4, 0.35), false)


## An arrow on the screen edge pointing at a world position, if that position is off screen.
func _arrow(world: Vector2, color: Color, diamond: bool) -> void:
	# world -> viewport pixels -> this control's own coordinates (its layer carries the UI scale)
	var at: Vector2 = get_global_transform_with_canvas().affine_inverse() * (get_viewport().get_canvas_transform() * world)
	var rect := Rect2(Vector2.ZERO, size).grow(-MARGIN)
	if rect.has_point(at):
		return
	var center := rect.get_center()
	var dir := (at - center).normalized()
	# walk from the centre to the rectangle's edge along dir
	var scale_x := (rect.size.x / 2) / absf(dir.x) if dir.x != 0.0 else INF
	var scale_y := (rect.size.y / 2) / absf(dir.y) if dir.y != 0.0 else INF
	var tip := center + dir * minf(scale_x, scale_y)
	var side := dir.orthogonal() * SIZE * 0.7
	draw_colored_polygon(PackedVector2Array([tip, tip - dir * SIZE * 1.6 + side, tip - dir * SIZE * 1.6 - side]), color)
	if diamond:
		var c := tip - dir * SIZE * 3.2
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -3), c + Vector2(2, 0), c + Vector2(0, 3), c + Vector2(-2, 0)]), color)
