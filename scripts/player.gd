class_name Player
extends CharacterBody2D

signal died
signal teleport_interrupted

const SPEED := 70.0
## Attacks leave from the chest, not the feet (the node origin).
const MUZZLE := Vector2(0, -7)
## Seconds standing still to teleport home; any damage taken breaks it off.
const TELEPORT_TIME := 3.0
const RESPAWN_TIME := 5.0
## Out of combat for this long, health comes back at this fraction of the maximum per second.
const REGEN_DELAY := 4.0
const REGEN_RATE := 0.03
const HURT_COLOR := Color(1, 0.4, 0.4)

@export var player_class: PlayerClass
## Where teleports and respawns land.
@export var home: Athena

var stats: CharacterStats
var _cooldown := 0.0
## Seconds into the teleport cast; negative while not casting.
var _teleport := -1.0
var _since_hurt := INF
var _respawn := 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _cast_bar: ProgressBar = $CastBar


func _ready() -> void:
	stats = CharacterStats.new(player_class)
	DevTools.edit_character(stats)


func _exit_tree() -> void:
	DevTools.edit_character(null)


func is_alive() -> bool:
	return stats.hp > 0.0


func is_teleporting() -> bool:
	return _teleport >= 0.0


## Takes an enemy hit through armor; returns the health actually lost.
func take_damage(amount: float) -> float:
	if not is_alive():
		return 0.0
	var dealt := stats.hurt(amount)
	_since_hurt = 0.0
	FloatingText.spawn(get_parent(), global_position + Vector2(0, -16), "-%d" % ceili(dealt), HURT_COLOR)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.2).from(HURT_COLOR)
	if is_teleporting():
		_cancel_teleport()
		teleport_interrupted.emit()
	if not is_alive():
		_die()
	return dealt


func heal_full() -> void:
	stats.heal(stats.max_hp())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("teleport") and is_alive():
		if is_teleporting():
			_cancel_teleport()
		else:
			_teleport = 0.0
			_cast_bar.visible = true


func _physics_process(delta: float) -> void:
	if not is_alive():
		_respawn -= delta
		if _respawn <= 0.0:
			_arrive_home()
			heal_full()
			show()
		return
	_since_hurt += delta
	if _since_hurt > REGEN_DELAY and stats.hp < stats.max_hp():
		stats.heal(stats.max_hp() * REGEN_RATE * delta)
	if is_teleporting():
		_channel(delta)
		return
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * SPEED * stats.move_speed()
	move_and_slide()
	_sprite.play("walk" if input != Vector2.ZERO else "idle")

	_cooldown -= delta
	if Input.is_action_pressed("attack") and _cooldown <= 0.0 and not get_viewport().gui_get_hovered_control():
		var aim := get_global_mouse_position() - (global_position + MUZZLE)
		_attack(aim.angle())
		_face(aim.x)
	elif _cooldown <= 0.0:
		_face(input.x)


func _attack(angle: float) -> void:
	_cooldown = stats.cooldown()
	var attack: Attack = player_class.attack_scene.instantiate()
	attack.position = position + MUZZLE
	attack.rotation = angle
	attack.damage = stats.damage()
	attack.crit_chance = stats.crit_chance()
	attack.crit_multiplier = stats.crit_multiplier()
	attack.landed.connect(func(target: Hurtbox) -> void: stats.add_experience(target.exp_per_hit))
	get_parent().add_child(attack)


## Rooted in place while the bar fills; then home.
func _channel(delta: float) -> void:
	velocity = Vector2.ZERO
	_sprite.play("idle")
	_teleport += delta
	_cast_bar.value = _teleport / TELEPORT_TIME
	if _teleport >= TELEPORT_TIME:
		_cancel_teleport()
		Blast.spawn(get_parent(), global_position, 12, Athena.COLOR)
		_arrive_home()
		Blast.spawn(get_parent(), global_position, 12, Athena.COLOR)


func _cancel_teleport() -> void:
	_teleport = -1.0
	_cast_bar.visible = false


func _arrive_home() -> void:
	global_position = home.arrival_point()
	get_viewport().get_camera_2d().reset_smoothing()


func _die() -> void:
	_respawn = RESPAWN_TIME
	hide()
	died.emit()


## The art only faces right, so left is a horizontal flip.
func _face(x: float) -> void:
	if x != 0.0:
		_sprite.flip_h = x < 0.0
