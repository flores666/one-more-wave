## The rules of one run: the phase state machine, the wave number, Athena's health, the picked
## enemy modifiers and the loot they earn. Plain data: scene nodes call in and listen to signals.
##
## FARMING --timer--> INVASION --cleared--> WAVE_COMPLETED --delay--> MODIFIER_SELECTION --choose--> FARMING
## Athena reaching zero health from any phase ends the run in DEFEAT.
class_name Run
extends RefCounted

signal phase_changed(phase: Phase)
signal base_hp_changed
signal modifiers_changed
signal gold_changed

enum Phase { FARMING, INVASION, WAVE_COMPLETED, MODIFIER_SELECTION, DEFEAT }

const PHASE_NAMES := ["Farming", "Invasion", "Wave cleared", "Modifier selection", "Defeat"]

var config: RunConfig
## The wave being farmed for or fought; goes up when an invasion is beaten.
var wave := 1
var phase := Phase.FARMING
## Seconds until the timed phases (FARMING, WAVE_COMPLETED) move on.
var time_left := 0.0
var base_hp := 0.0
## Every pick in order; a modifier picked twice appears twice.
var modifiers: Array[EnemyModifier] = []
## The offer during MODIFIER_SELECTION.
var choices: Array[EnemyModifier] = []
var gold := 0
var rng := RandomNumberGenerator.new()

var _bonus_loot := 0.0
var _bonus_loot_time := 0.0


func _init(from: RunConfig) -> void:
	config = from
	base_hp = config.base_max_hp
	_enter(Phase.FARMING, config.first_farming_duration)


func advance(delta: float) -> void:
	_bonus_loot_time = maxf(_bonus_loot_time - delta, 0.0)
	if phase not in [Phase.FARMING, Phase.WAVE_COMPLETED]:
		return
	time_left = maxf(time_left - delta, 0.0)
	if time_left > 0.0:
		return
	if phase == Phase.FARMING:
		_enter(Phase.INVASION)
	else:
		_offer_choices()


## Skips the rest of the farming timer.
func call_invasion() -> void:
	if phase == Phase.FARMING:
		_enter(Phase.INVASION)


func invasion_cleared() -> void:
	assert(phase == Phase.INVASION)
	wave += 1
	base_hp = minf(base_hp + config.base_max_hp * config.base_heal_per_wave, config.base_max_hp)
	base_hp_changed.emit()
	_enter(Phase.WAVE_COMPLETED, config.wave_cleared_delay)


func choose(index: int) -> void:
	assert(phase == Phase.MODIFIER_SELECTION)
	modifiers.append(choices[index])
	choices.clear()
	modifiers_changed.emit()
	_enter(Phase.FARMING, config.farming_duration)


func damage_base(amount: float) -> void:
	if phase == Phase.DEFEAT:
		return
	base_hp = maxf(base_hp - amount, 0.0)
	base_hp_changed.emit()
	if base_hp == 0.0:
		_enter(Phase.DEFEAT)


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit()


func add_loot_bonus(amount: float, seconds: float) -> void:
	_bonus_loot = amount
	_bonus_loot_time = seconds
	modifiers_changed.emit()


func loot_multiplier() -> float:
	var total := 1.0 + bonus_loot()
	for modifier in modifiers:
		total += modifier.loot_bonus
	return total


## The temporary quest bonus, while it lasts.
func bonus_loot() -> float:
	return _bonus_loot if _bonus_loot_time > 0.0 else 0.0


func bonus_loot_time() -> float:
	return _bonus_loot_time


func stacks(modifier: EnemyModifier) -> int:
	return modifiers.count(modifier)


func extra_elites() -> int:
	var total := 0
	for modifier in modifiers:
		total += modifier.extra_elites
	return total


func _offer_choices() -> void:
	var pool := config.modifiers.filter(func(m: EnemyModifier) -> bool:
		return m.max_stacks == 0 or stacks(m) < m.max_stacks)
	# Fisher-Yates with the run's generator, so a seeded run offers the same cards
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: EnemyModifier = pool[i]
		pool[i] = pool[j]
		pool[j] = swap
	choices.assign(pool.slice(0, config.choice_count))
	_enter(Phase.MODIFIER_SELECTION)


func _enter(next: Phase, duration := 0.0) -> void:
	phase = next
	time_left = duration
	phase_changed.emit(phase)
