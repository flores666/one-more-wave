## A character's level, experience, primary stats and equipment, and the combat numbers they derive.
## A primary stat is the class base, plus the class growth for every level gained,
## plus whatever the developer added on top in the F1 panel. Equipment adds flat bonuses on top.
class_name CharacterStats
extends RefCounted

signal changed
signal leveled_up

## STR, AGI, INT, LUK: each class scales damage off one (PlayerClass.main_stat),
## AGI speeds up attacks and movement, LUK raises crit chance and crit damage.
const STATS: Array[String] = ["str", "agi", "int", "luk"]
const MAX_LEVEL := 99
const MAX_STAT := 999

## Experience for the next level: EXP_BASE * level ^ EXP_CURVE.
const EXP_BASE := 30.0
const EXP_CURVE := 1.5

const DAMAGE_PER_MAIN_STAT := 0.03
const ATTACK_SPEED_PER_AGI := 0.01
## However much AGI, attacks never come faster than this many seconds apart.
const MIN_COOLDOWN := 0.08
const MOVE_SPEED_PER_AGI := 0.004
const MAX_MOVE_BONUS := 0.5
const BASE_CRIT_CHANCE := 0.1
const CRIT_CHANCE_PER_LUK := 0.01
const BASE_CRIT_DAMAGE := 1.5
const CRIT_DAMAGE_PER_LUK := 0.02

## Health at level 1 before equipment, and what each level adds.
const MAX_HP := 20
const HP_PER_LEVEL := 4
## Armor A takes A / (A + ARMOR_FACTOR) off every hit.
const ARMOR_FACTOR := 40.0
## Mana and stamina start full at these maximums; nothing spends them yet.
const MAX_MP := 10
const MAX_STAMINA := 10

var player_class: PlayerClass
var level := 1
var experience := 0
var hp := float(MAX_HP)
var mp := MAX_MP
var stamina := MAX_STAMINA
var inventory := Inventory.new()
var _bonus: Dictionary[String, int] = {}


func _init(from_class: PlayerClass) -> void:
	player_class = from_class
	for key in STATS:
		_bonus[key] = 0
	inventory.changed.connect(_on_gear_changed)


func get_stat(key: String) -> int:
	return maxi(_grown(key) + _bonus[key], 0)


func set_stat(key: String, value: int) -> void:
	_bonus[key] = clampi(value, 0, MAX_STAT) - _grown(key)
	changed.emit()


func set_level(value: int) -> void:
	level = clampi(value, 1, MAX_LEVEL)
	experience = 0
	hp = max_hp()
	changed.emit()


func exp_to_next_level() -> int:
	return roundi(EXP_BASE * pow(level, EXP_CURVE))


func add_experience(amount: int) -> void:
	if level >= MAX_LEVEL or amount <= 0:
		return
	experience += amount
	var gained := false
	while level < MAX_LEVEL and experience >= exp_to_next_level():
		experience -= exp_to_next_level()
		level += 1
		gained = true
	if level >= MAX_LEVEL:
		experience = 0
	if gained:
		hp = max_hp()
	changed.emit()
	if gained:
		leveled_up.emit()


func damage() -> float:
	var base := player_class.base_damage + inventory.bonus("damage")
	return base * (1.0 + DAMAGE_PER_MAIN_STAT * get_stat(player_class.main_stat))


## Multiplier on attack rate: 1.5 means 50% more attacks per second.
func attack_speed() -> float:
	return 1.0 + ATTACK_SPEED_PER_AGI * get_stat("agi") + inventory.bonus("attack_speed")


func cooldown() -> float:
	return maxf(player_class.cooldown / attack_speed(), MIN_COOLDOWN)


func move_speed() -> float:
	return 1.0 + minf(MOVE_SPEED_PER_AGI * get_stat("agi"), MAX_MOVE_BONUS)


func crit_chance() -> float:
	return minf(BASE_CRIT_CHANCE + CRIT_CHANCE_PER_LUK * get_stat("luk") + inventory.bonus("crit_chance"), 1.0)


func crit_multiplier() -> float:
	return BASE_CRIT_DAMAGE + CRIT_DAMAGE_PER_LUK * get_stat("luk")


func max_hp() -> float:
	return MAX_HP + HP_PER_LEVEL * (level - 1) + inventory.bonus("max_hp")


func armor() -> float:
	return inventory.bonus("armor")


## Takes a hit reduced by armor and returns the damage actually lost.
func hurt(amount: float) -> float:
	var dealt := minf(amount * ARMOR_FACTOR / (ARMOR_FACTOR + armor()), hp)
	hp -= dealt
	changed.emit()
	return dealt


func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp())
	changed.emit()


func _on_gear_changed() -> void:
	hp = minf(hp, max_hp())
	changed.emit()


func _grown(key: String) -> int:
	return player_class.base_stats.get(key, 0) + player_class.stats_per_level.get(key, 0) * (level - 1)
