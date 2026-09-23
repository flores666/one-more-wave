class_name Hurtbox
extends Area2D

signal hit(damage: float, crit: bool)

## Experience the attacker earns for each hit landed here.
@export var exp_per_hit := 0


func receive(damage: float, crit: bool) -> void:
	hit.emit(damage, crit)
