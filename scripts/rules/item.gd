## One piece of equipment: a slot, a rarity, an item level and its rolled stats.
class_name Item
extends RefCounted

enum Slot { WEAPON, HELMET, CHEST, BOOTS, RING }
enum Rarity { COMMON, MAGIC, RARE, EPIC }

const SLOT_NAMES: Array[String] = ["Weapon", "Helmet", "Chest", "Boots", "Ring"]
const RARITY_NAMES: Array[String] = ["Common", "Magic", "Rare", "Epic"]
const RARITY_COLORS: Array[Color] = [
	Color(0.9, 0.88, 0.84), Color(0.45, 0.65, 1.0), Color(1, 0.82, 0.25), Color(0.8, 0.5, 1.0),
]
## Every stat an item can carry. Percent stats are stored as fractions.
const STATS: Array[String] = ["damage", "max_hp", "armor", "attack_speed", "crit_chance"]
const PERCENT_STATS: Array[String] = ["attack_speed", "crit_chance"]
const STAT_LABELS := {"damage": "DMG", "max_hp": "HP", "armor": "ARM", "attack_speed": "APS", "crit_chance": "CRIT"}

var slot := Slot.WEAPON
var rarity := Rarity.COMMON
var level := 1
var stats: Dictionary[String, float] = {}


func title() -> String:
	return "%s %s" % [RARITY_NAMES[rarity], SLOT_NAMES[slot]]


func color() -> Color:
	return RARITY_COLORS[rarity]


func get_stat(key: String) -> float:
	return stats.get(key, 0.0)


## "+3 DMG", "+6% APS"; negative values read "-3 DMG".
static func format_stat(key: String, value: float) -> String:
	var prefix := "+" if value >= 0.0 else "-"
	if key in PERCENT_STATS:
		return "%s%d%% %s" % [prefix, roundi(absf(value) * 100), STAT_LABELS[key]]
	return "%s%d %s" % [prefix, roundi(absf(value)), STAT_LABELS[key]]
