## Athena, the base: the crystal invaders march on. Her health lives in the Run; this node is her
## body in the world, with a health bar and hit feedback.
class_name Athena
extends Node2D

const COLOR := Color(0.482, 0.765, 0.824)
const HIT_COLOR := Color(1, 0.35, 0.3)
## Where the player lands after a teleport or respawn, relative to the crystal.
const ARRIVAL := Vector2(0, 18)

var run: Run
var _flash := 0.0
var _t := 0.0

@onready var _bar: ProgressBar = $Bar


func setup(from: Run) -> void:
	run = from
	run.base_hp_changed.connect(_refresh)
	_refresh()


func take_damage(amount: float) -> float:
	run.damage_base(amount)
	_flash = 1.0
	return amount


func arrival_point() -> Vector2:
	return global_position + ARRIVAL


func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(_flash - delta * 4.0, 0.0)
	queue_redraw()


## A floating diamond crystal above the altar circle, bobbing by a pixel and flashing red when hit.
func _draw() -> void:
	var y := -12.0 + roundf(sin(_t * 2.0))
	var color := COLOR.lerp(HIT_COLOR, _flash)
	var points := PackedVector2Array([Vector2(0, y - 7), Vector2(4, y), Vector2(0, y + 7), Vector2(-4, y)])
	draw_colored_polygon(points, color)
	draw_polyline(points + PackedVector2Array([points[0]]), color.darkened(0.5), 1.0)
	draw_line(Vector2(0, y - 5), Vector2(0, y + 5), color.lightened(0.5), 1.0)


func _refresh() -> void:
	_bar.max_value = run.config.base_max_hp
	_bar.value = run.base_hp
