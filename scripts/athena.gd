## Athena, the base: the crystal invaders march on. Her health lives in the Run; this node is her
## body in the world, with a health bar and a red flash when hit. The crystal bobs by itself
## (AnimationPlayer); the flash tints its body.
class_name Athena
extends Node2D

@export var color := Color(0.482, 0.765, 0.824)
@export var hit_color := Color(1, 0.35, 0.3)
@export var flash_time := 0.25
## Where the player lands after a teleport or respawn, relative to the crystal.
@export var arrival := Vector2(0, 18)

var run: Run

@onready var _bar: ProgressBar = $Bar
@onready var _tint: Node2D = $Crystal/Tint


func setup(from: Run) -> void:
	run = from
	run.base_hp_changed.connect(_refresh)
	_refresh()


func take_damage(amount: float) -> float:
	run.damage_base(amount)
	create_tween().tween_property(_tint, "modulate", color, flash_time).from(hit_color)
	return amount


func arrival_point() -> Vector2:
	return global_position + arrival


func _refresh() -> void:
	_bar.max_value = run.config.base_max_hp
	_bar.value = run.base_hp
