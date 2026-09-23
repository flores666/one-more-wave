## Which enemies make up each invasion, and how every enemy grows stronger wave after wave.
## Open-ended: rules keep matching and counts keep growing past wave 100.
class_name WaveTable
extends Resource

@export var rules: Array[WaveRule] = []
## Health and damage grow by these fractions of their wave 1 value for every wave after the first.
@export var hp_growth := 0.15
@export var damage_growth := 0.08
## Joins the invasion once per stack of modifiers that add elites.
@export var extra_elite: EnemyType


func compose(wave: int, extra_elites := 0) -> Array[EnemyType]:
	var out: Array[EnemyType] = []
	for rule in rules:
		for i in rule.count_for(wave):
			out.append(rule.enemy)
	for i in extra_elites:
		out.append(extra_elite)
	return out


func hp_scale(wave: int) -> float:
	return 1.0 + hp_growth * (wave - 1)


func damage_scale(wave: int) -> float:
	return 1.0 + damage_growth * (wave - 1)
