## A patch of the world that keeps roaming monsters around for farming, with a chance of elites and,
## from boss_from_wave on, a boss that returns at the start of every farming phase until killed.
class_name FarmZone
extends Node2D

@export var spawner: EnemySpawner
@export var enemies: Array[EnemyType] = []
@export var max_alive := 5
@export var radius := 60.0
@export var respawn_delay := 5.0
@export var elite: EnemyType
@export_range(0.0, 1.0) var elite_chance := 0.1
@export var boss: EnemyType
@export var boss_from_wave := 3

var run: Run
var _alive: Array[Enemy] = []
var _boss: Enemy
var _respawn := 0.0


func start_farming() -> void:
	if boss and run.wave >= boss_from_wave and not is_instance_valid(_boss):
		_boss = spawner.spawn(boss, global_position, false)
	while _alive.size() < max_alive:
		_spawn_one()


func has_boss() -> bool:
	return is_instance_valid(_boss)


func _process(delta: float) -> void:
	if run == null or _alive.size() >= max_alive:
		return
	_respawn -= delta
	if _respawn <= 0.0:
		_respawn = respawn_delay
		_spawn_one()


func _spawn_one() -> void:
	var type: EnemyType = enemies[run.rng.randi_range(0, enemies.size() - 1)]
	if elite and run.rng.randf() < elite_chance:
		type = elite
	var at := global_position + Vector2.from_angle(run.rng.randf() * TAU) * run.rng.randf() * radius
	var enemy := spawner.spawn(type, at, false)
	_alive.append(enemy)
	enemy.died.connect(func(e: Enemy) -> void: _alive.erase(e))
