## A flat ring on the ground: grows over `time` for telegraphs, or flashes for explosions.
## Drawn rather than a sprite because every use has its own radius.
class_name Blast
extends Node2D

const SCENE_PATH := "res://scenes/blast.tscn"

var radius := 16.0
var color := Color.WHITE
var time := 0.3
var grow := false
var _t := 0.0


static func spawn(parent: Node, at: Vector2, radius: float, color: Color, time := 0.3, grow := false) -> Blast:
	var blast: Blast = load(SCENE_PATH).instantiate()
	blast.position = at
	blast.radius = radius
	blast.color = color
	blast.time = time
	blast.grow = grow
	parent.add_child(blast)
	return blast


func _process(delta: float) -> void:
	_t += delta
	if _t >= time:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(_t / time, 0.0, 1.0)
	if grow:
		# telegraph: the full outline, filling in until it goes off
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(color, 0.8), 1.0)
		draw_circle(Vector2.ZERO, radius * k, Color(color, 0.25))
	else:
		draw_circle(Vector2.ZERO, radius * (0.5 + 0.5 * k), Color(color, 0.5 * (1.0 - k)))
		draw_arc(Vector2.ZERO, radius * (0.5 + 0.5 * k), 0, TAU, 32, Color(color, 1.0 - k), 1.0)
