## A permanent enemy upgrade picked after a wave. Picks stack, and each one raises the loot multiplier.
class_name EnemyModifier
extends Resource

enum Target { ALL, NORMAL, ELITE, BOSS }

@export var title := ""
@export_multiline var description := ""
@export var loot_bonus := 0.1
## How often it can be picked in one run; 0 = no limit.
@export var max_stacks := 0
@export var target := Target.ALL
@export_group("Per stack")
## Fractions added to the affected enemies' multipliers.
@export var hp := 0.0
@export var speed := 0.0
@export var damage := 0.0
## Fraction of damage dealt that heals the attacker.
@export var lifesteal := 0.0
## Fraction of maximum health regenerated per second.
@export var regen := 0.0
## Extra damage against Athena only.
@export var siege := 0.0
## Elites added to every invasion.
@export var extra_elites := 0
## Behaviour granted to the affected enemies (see Enemy and EnemySpawner).
@export var ability := &""


func affects(tier: EnemyType.Tier) -> bool:
	return target == Target.ALL or target - 1 == tier
