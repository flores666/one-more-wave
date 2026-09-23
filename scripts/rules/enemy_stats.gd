## What one spawned enemy actually is: its type scaled to the wave and every picked modifier.
class_name EnemyStats
extends RefCounted

var type: EnemyType
var max_hp := 0.0
var damage := 0.0
var speed := 0.0
var lifesteal := 0.0
var regen := 0.0
## Damage multiplier against Athena.
var siege := 1.0
var experience := 0
var abilities: Array[StringName] = []
## Visual scale; split offspring are smaller.
var size := 1.0
## Fraction of the type's loot this enemy drops.
var loot_share := 1.0


static func build(from: EnemyType, run: Run) -> EnemyStats:
	var s := EnemyStats.new()
	s.type = from
	s.size = from.size
	s.abilities = from.abilities.duplicate()
	var hp_bonus := 0.0
	var speed_bonus := 0.0
	var damage_bonus := 0.0
	for modifier in run.modifiers:
		if not modifier.affects(from.tier):
			continue
		hp_bonus += modifier.hp
		speed_bonus += modifier.speed
		damage_bonus += modifier.damage
		s.lifesteal += modifier.lifesteal
		s.regen += modifier.regen
		s.siege += modifier.siege
		if modifier.ability != &"" and modifier.ability not in s.abilities:
			s.abilities.append(modifier.ability)
	var table := run.config.waves
	s.max_hp = from.max_hp * table.hp_scale(run.wave) * (1.0 + hp_bonus)
	s.damage = from.damage * table.damage_scale(run.wave) * (1.0 + damage_bonus)
	s.speed = from.speed * (1.0 + speed_bonus)
	s.experience = roundi(from.experience * (1.0 + 0.1 * (run.wave - 1)))
	return s


## A smaller, weaker copy that does not split again.
func split() -> EnemyStats:
	var s: EnemyStats = EnemyStats.new()
	s.type = type
	s.max_hp = max_hp * 0.4
	s.damage = damage * 0.5
	s.speed = speed * 1.2
	s.lifesteal = lifesteal
	s.regen = regen
	s.siege = siege
	s.experience = ceili(experience * 0.3)
	s.abilities = abilities.filter(func(a: StringName) -> bool: return a != &"split")
	s.size = size * 0.7
	s.loot_share = 0.3
	return s
