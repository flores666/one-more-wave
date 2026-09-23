## A monster in the world. Invaders march on Athena and only turn on a player who gets close or hits
## them; roaming farm monsters wander near home, chase a player who comes near and give up past a leash.
##
## Abilities (from the type or a run modifier): "slam" telegraphed area hit, "dash" charge,
## "enrage" faster and harder below 40% health. "explode" and "split" happen on death (EnemySpawner).
class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)

## Roaming monsters notice a player this close; invaders only turn aside for one this close.
const AGGRO_RANGE := 56.0
const INVADER_AGGRO := 28.0
## After being hit, a monster keeps after the player for this long and from this much further.
const PROVOKED_TIME := 3.0
const PROVOKED_RANGE := 90.0
## Roaming monsters give up a chase this far from home.
const LEASH := 150.0
const WANDER_RADIUS := 40.0
const ENRAGE_BELOW := 0.4
const ENRAGE_BOOST := 1.5
const DASH_COOLDOWN := 4.0
const DASH_TIME := 0.35
const DASH_SPEED := 3.5
const SLAM_COOLDOWN := 5.0
const SLAM_WINDUP := 0.8
const SLAM_RADIUS := 30.0
const SLAM_DAMAGE := 1.5
const HIT_FLASH := 0.15

@export var hit_color := Color.WHITE
@export var crit_color := Color(1, 0.82, 0.25)
@export var slam_warning_color := Color(1, 0.3, 0.2)
@export var slam_color := Color(1, 0.5, 0.3)

var stats: EnemyStats
var hp := 0.0
## Athena for invaders; null for roaming monsters.
var objective: Athena
var player: Player
var home := Vector2.ZERO

var _attack_cd := 0.0
var _provoked := 0.0
var _wander_to := Vector2.ZERO
var _wander_wait := 0.0
var _dash_cd := DASH_COOLDOWN
var _dash_left := 0.0
var _slam_cd := SLAM_COOLDOWN
var _slam_left := -1.0
## Where around Athena this one stands, so a crowd surrounds her instead of stacking on one pixel.
var _approach := Vector2.ZERO
var _dead := false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _material: ShaderMaterial = _sprite.material
@onready var _bar: ProgressBar = $Bar


func setup(from: EnemyStats, target_player: Player, target_base: Athena) -> void:
	stats = from
	player = target_player
	objective = target_base


func _ready() -> void:
	hp = stats.max_hp
	home = global_position
	_wander_to = home
	_approach = Vector2.from_angle(randf() * TAU) * randf_range(6.0, 14.0)
	_sprite.scale = Vector2.ONE * stats.size
	_material.set_shader_parameter("body", stats.type.body_color)
	_material.set_shader_parameter("eyes", stats.type.eye_color)
	_bar.position.y = -18 * stats.size - 4
	_bar.visible = false
	$Hurtbox.hit.connect(_on_hit)
	$Hurtbox.scale = Vector2.ONE * stats.size


func _physics_process(delta: float) -> void:
	_attack_cd -= delta
	_provoked -= delta
	_dash_cd -= delta
	_slam_cd -= delta
	if stats.regen > 0.0 and hp < stats.max_hp:
		hp = minf(hp + stats.max_hp * stats.regen * delta, stats.max_hp)
		_bar.value = hp
	if _slam_left >= 0.0:
		_tick_slam(delta)
		return
	var target := _pick_target()
	if target == null:
		_wander(delta)
		return
	var goal := target.global_position + (_approach if target == objective else Vector2.ZERO)
	var to := goal - global_position
	if &"slam" in stats.abilities and _slam_cd <= 0.0 and target == player and to.length() < SLAM_RADIUS:
		_start_slam()
		return
	if &"dash" in stats.abilities and _dash_cd <= 0.0 and to.length() > 20.0 and to.length() < 90.0:
		_dash_cd = DASH_COOLDOWN
		_dash_left = DASH_TIME
	_dash_left -= delta
	if to.length() > stats.type.attack_range:
		_move(to.normalized() * stats.speed * _boost() * (DASH_SPEED if _dash_left > 0.0 else 1.0))
	else:
		_move(Vector2.ZERO)
		_face(to.x)
		if _attack_cd <= 0.0:
			_attack(target)


func is_invader() -> bool:
	return objective != null


func _pick_target() -> Node2D:
	var near := INF
	if player and player.is_alive():
		near = global_position.distance_to(player.global_position)
	var provoked := _provoked > 0.0 and near < PROVOKED_RANGE
	if objective:
		return player if near < INVADER_AGGRO or provoked else objective
	if (near < AGGRO_RANGE or provoked) and global_position.distance_to(home) < LEASH:
		return player
	return null


func _wander(delta: float) -> void:
	if global_position.distance_to(_wander_to) < 3.0:
		_wander_wait -= delta
		_move(Vector2.ZERO)
		if _wander_wait <= 0.0:
			_wander_to = home + Vector2.from_angle(randf() * TAU) * randf() * WANDER_RADIUS
			_wander_wait = randf_range(1.0, 3.0)
		return
	# heading back from a chase is brisk, strolling about is not
	var far := global_position.distance_to(home) > WANDER_RADIUS * 1.5
	_move((_wander_to - global_position).normalized() * stats.speed * (1.0 if far else 0.4))


func _move(v: Vector2) -> void:
	velocity = v
	move_and_slide()
	_sprite.play("walk" if v != Vector2.ZERO else "idle")
	_face(v.x)


func _attack(target: Node2D) -> void:
	_attack_cd = stats.type.attack_cooldown
	var amount := stats.damage * _boost()
	if target == objective:
		amount *= stats.siege
	var dealt: float = target.take_damage(amount)
	if stats.lifesteal > 0.0:
		hp = minf(hp + dealt * stats.lifesteal, stats.max_hp)
		_bar.value = hp
	# lunge a few pixels at the target
	var lunge := (target.global_position - global_position).normalized() * 3.0
	var tween := create_tween()
	tween.tween_property(_sprite, "position", lunge, 0.06)
	tween.tween_property(_sprite, "position", Vector2.ZERO, 0.12)


func _start_slam() -> void:
	_slam_cd = SLAM_COOLDOWN
	_slam_left = SLAM_WINDUP
	_move(Vector2.ZERO)
	Blast.spawn(get_parent(), global_position, SLAM_RADIUS, slam_warning_color, SLAM_WINDUP, true)


func _tick_slam(delta: float) -> void:
	_slam_left -= delta
	if _slam_left >= 0.0:
		return
	Blast.spawn(get_parent(), global_position, SLAM_RADIUS, slam_color)
	if player and player.is_alive() and global_position.distance_to(player.global_position) < SLAM_RADIUS:
		player.take_damage(stats.damage * SLAM_DAMAGE * _boost())


func _boost() -> float:
	var enraged := &"enrage" in stats.abilities and hp < stats.max_hp * ENRAGE_BELOW
	return ENRAGE_BOOST if enraged else 1.0


func _on_hit(damage: float, crit: bool) -> void:
	if _dead:
		return
	hp -= damage
	_provoked = PROVOKED_TIME
	_bar.visible = true
	_bar.max_value = stats.max_hp
	_bar.value = hp
	FloatingText.spawn(get_parent(), global_position + Vector2(0, -18 * stats.size),
			("%d!" if crit else "%d") % roundi(damage), crit_color if crit else hit_color)
	create_tween().tween_property(_material, "shader_parameter/flash", 0.0, HIT_FLASH).from(1.0)
	if hp <= 0.0:
		_dead = true
		died.emit(self)
		queue_free()


## The art only faces right, so left is a horizontal flip.
func _face(x: float) -> void:
	if x != 0.0:
		_sprite.flip_h = x < 0.0
