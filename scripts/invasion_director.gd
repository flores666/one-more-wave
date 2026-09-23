## Runs the Invasion phase: marches the wave's enemies in from the map edge in groups, from more
## directions as waves go up, and reports when every invader (split offspring included) is dead.
class_name InvasionDirector
extends Node

signal cleared

@export var spawner: EnemySpawner
## Marker2D children mark the edge positions invaders enter from.
@export var spawn_points: Node2D
@export var group_size := 4
@export var group_interval := 2.5
## One more entry direction every this many waves.
@export var waves_per_direction := 3

var run: Run
var _queue: Array[EnemyType] = []
var _entries: Array[Vector2] = []
var _alive := 0
var _next_group := 0.0
var _active := false


func _ready() -> void:
	spawner.spawned.connect(func(enemy: Enemy) -> void: _alive += 1 if enemy.is_invader() else 0)
	spawner.died.connect(_on_died)


func start() -> void:
	_queue = run.config.waves.compose(run.wave, run.extra_elites())
	# rank and file first, then elites, then bosses
	var by_tier: Array[EnemyType] = []
	for tier in EnemyType.Tier.values():
		by_tier.append_array(_queue.filter(func(t: EnemyType) -> bool: return t.tier == tier))
	_queue = by_tier
	var points: Array = spawn_points.get_children().map(func(m: Node2D) -> Vector2: return m.global_position)
	_entries.clear()
	var directions := mini(1 + (run.wave - 1) / waves_per_direction, points.size())
	for i in directions:
		_entries.append(points.pop_at(run.rng.randi_range(0, points.size() - 1)))
	_next_group = 0.0
	_active = true


func remaining() -> int:
	return _queue.size() + _alive


## Where this wave's invaders enter, for the HUD's warning.
func entries() -> Array[Vector2]:
	return _entries


func _process(delta: float) -> void:
	if not _active:
		return
	_next_group -= delta
	if _next_group <= 0.0 and not _queue.is_empty():
		_next_group = group_interval
		var entry: Vector2 = _entries[run.rng.randi_range(0, _entries.size() - 1)]
		for i in mini(group_size, _queue.size()):
			var offset := Vector2(run.rng.randf_range(-12, 12), run.rng.randf_range(-12, 12))
			spawner.spawn(_queue.pop_front(), entry + offset, true)
	if _queue.is_empty() and _alive == 0:
		_active = false
		cleared.emit()


func _on_died(enemy: Enemy) -> void:
	if enemy.is_invader():
		_alive -= 1
