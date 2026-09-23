## Creates every enemy (for the invasion and the farm zones) with its stats built from the Run,
## and plays out on-death abilities: "explode" hurts the player and Athena nearby, "split" leaves
## two smaller copies behind. Everything else about a death goes out through `died`.
class_name EnemySpawner
extends Node

signal spawned(enemy: Enemy)
signal died(enemy: Enemy)

const ENEMY := preload("res://scenes/enemy.tscn")
const EXPLODE_RADIUS := 22.0
## Explosion damage as a fraction of the enemy's own hit.
const EXPLODE_DAMAGE := 1.5

@export var entities: Node2D
@export var player: Player
@export var athena: Athena
@export var explode_color := Color(1, 0.55, 0.2)

var run: Run


func spawn(type: EnemyType, at: Vector2, invader: bool) -> Enemy:
	return _add(EnemyStats.build(type, run), at, invader)


func _add(stats: EnemyStats, at: Vector2, invader: bool) -> Enemy:
	var enemy: Enemy = ENEMY.instantiate()
	enemy.setup(stats, player, athena if invader else null)
	enemy.position = at
	enemy.died.connect(_on_died)
	entities.add_child(enemy)
	spawned.emit(enemy)
	return enemy


func _on_died(enemy: Enemy) -> void:
	var at := enemy.global_position
	if &"explode" in enemy.stats.abilities:
		_explode(at, enemy.stats.damage * EXPLODE_DAMAGE)
	if &"split" in enemy.stats.abilities:
		for side in [-1, 1]:
			_add.call_deferred(enemy.stats.split(), at + Vector2(side * 5, 0), enemy.is_invader())
	died.emit(enemy)


func _explode(at: Vector2, damage: float) -> void:
	Blast.spawn(entities, at, EXPLODE_RADIUS, explode_color)
	if player.is_alive() and player.global_position.distance_to(at) < EXPLODE_RADIUS:
		player.take_damage(damage)
	if athena.global_position.distance_to(at) < EXPLODE_RADIUS:
		athena.take_damage(damage)
