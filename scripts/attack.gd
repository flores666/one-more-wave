## Shared by every class attack: projectiles fly along their rotation, melee effects stay put.
## Damage and crit come from the attacker's stats when it spawns the attack.
class_name Attack
extends Area2D

## Emitted for every hurtbox this attack damages.
signal landed(target: Hurtbox)

@export var speed := 0.0
@export var lifetime := 1.0
## Projectiles vanish on the first hit; melee effects damage everything they overlap.
@export var destroy_on_hit := true

var damage := 0.0
var crit_chance := 0.0
var crit_multiplier := 1.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime, false).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var crit := randf() < crit_chance
		area.receive(damage * crit_multiplier if crit else damage, crit)
		landed.emit(area)
		if destroy_on_hit:
			queue_free()
