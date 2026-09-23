## One kind of enemy: its numbers at wave 1, before wave scaling and run modifiers.
class_name EnemyType
extends Resource

enum Tier { NORMAL, ELITE, BOSS }

@export var id := &""
@export var display_name := ""
@export var tier := Tier.NORMAL
@export var max_hp := 30.0
@export var damage := 3.0
@export var speed := 30.0
@export var attack_range := 10.0
@export var attack_cooldown := 1.0
@export var experience := 8
## Gold coins dropped on death, before the loot multiplier.
@export var gold := 1
## Expected items dropped, before the loot multiplier: 0.1 is a 10% chance, 2.5 is two items and a 50% chance of a third.
@export var items := 0.08
## Added to the rarity roll of this enemy's items.
@export var loot_quality := 0.0
## Behaviours it always has, on top of any a modifier grants (see Enemy).
@export var abilities: Array[StringName] = []
@export var body_color := Color(0.7, 0.2, 0.2)
@export var eye_color := Color(1, 0.85, 0.3)
@export var size := 1.0
