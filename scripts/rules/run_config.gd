## Tuning for one run of the defend-and-farm loop.
class_name RunConfig
extends Resource

@export var first_farming_duration := 60.0
@export var farming_duration := 90.0
## Seconds between the last invader dying and the modifier choice.
@export var wave_cleared_delay := 2.5
@export var base_max_hp := 200.0
## Fraction of Athena's maximum health restored after each cleared wave.
@export var base_heal_per_wave := 0.25
@export var choice_count := 3
@export var waves: WaveTable
@export var modifiers: Array[EnemyModifier] = []
