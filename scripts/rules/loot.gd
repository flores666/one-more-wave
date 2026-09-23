## Loot rules: what a dead enemy drops and how equipment is rolled. Quality shifts the rarity odds
## towards the top; item level scales the numbers.
class_name Loot
extends RefCounted

const RARITY_WEIGHTS: Array[float] = [70.0, 22.0, 7.0, 1.0]
## Stat multiplier per rarity, and how many stats an item of that rarity carries.
const RARITY_POWER: Array[float] = [1.0, 1.25, 1.55, 2.0]
const RARITY_STAT_COUNT: Array[int] = [1, 2, 3, 4]
## The stat every item of a slot carries first.
const SLOT_STAT: Array[String] = ["damage", "max_hp", "armor", "attack_speed", "crit_chance"]
## [value at item level 0, growth per item level] before rarity; rolls land at 60-100% of it.
const STAT_RANGE := {
	"damage": [2.0, 0.6],
	"max_hp": [6.0, 2.0],
	"armor": [4.0, 1.5],
	"attack_speed": [0.06, 0.003],
	"crit_chance": [0.04, 0.002],
}
## Quality gained per wave, and item levels above the wave for elites and bosses.
const QUALITY_PER_WAVE := 0.08
const TIER_LEVELS: Array[int] = [0, 2, 4]


## {"gold": int, "items": Array[Item]} dropped by an enemy killed in this run.
static func drops_for(enemy: EnemyStats, run: Run, rng: RandomNumberGenerator) -> Dictionary:
	var multiplier := run.loot_multiplier() * enemy.loot_share
	var type := enemy.type
	var gold := _chance_count(type.gold * multiplier * rng.randf_range(0.6, 1.4), rng)
	var items: Array[Item] = []
	var quality := quality_for(run) + type.loot_quality
	for i in _chance_count(type.items * multiplier, rng):
		items.append(roll(run.wave + TIER_LEVELS[type.tier], quality, rng))
	return {"gold": gold, "items": items}


## Gold for an item there is no room for.
static func salvage_value(item: Item) -> int:
	return (item.rarity + 1) * (2 + item.level)


## Rarity odds in this run before the enemy's own bonus: better with waves and the loot multiplier.
static func quality_for(run: Run) -> float:
	return QUALITY_PER_WAVE * (run.wave - 1) + (run.loot_multiplier() - 1.0)


## A random item. slot -1 picks one at random; min_rarity raises a lower roll.
static func roll(level: int, quality: float, rng: RandomNumberGenerator, slot := -1,
		min_rarity := Item.Rarity.COMMON) -> Item:
	var item := Item.new()
	item.level = level
	item.slot = rng.randi_range(0, Item.SLOT_NAMES.size() - 1) if slot < 0 else slot
	item.rarity = maxi(_roll_rarity(quality, rng), min_rarity) as Item.Rarity
	var keys: Array[String] = [SLOT_STAT[item.slot]]
	var others := Item.STATS.filter(func(k: String) -> bool: return k != keys[0])
	while keys.size() < RARITY_STAT_COUNT[item.rarity]:
		var key: String = others.pop_at(rng.randi_range(0, others.size() - 1))
		keys.append(key)
	for key in keys:
		var r: Array = STAT_RANGE[key]
		var value: float = (r[0] + r[1] * level) * RARITY_POWER[item.rarity] * rng.randf_range(0.6, 1.0)
		item.stats[key] = value if key in Item.PERCENT_STATS else maxf(roundf(value), 1.0)
	return item


## Each rarity's weight grows by (1 + quality) for every step up, so quality favours the rare end.
static func _roll_rarity(quality: float, rng: RandomNumberGenerator) -> int:
	var weights: Array[float] = []
	for i in RARITY_WEIGHTS.size():
		weights.append(RARITY_WEIGHTS[i] * pow(1.0 + maxf(quality, 0.0), i))
	return rng.rand_weighted(PackedFloat32Array(weights))


## 2.3 becomes 2, or 3 with a 30% chance.
static func _chance_count(expected: float, rng: RandomNumberGenerator) -> int:
	var whole := floori(expected)
	return whole + (1 if rng.randf() < expected - whole else 0)
