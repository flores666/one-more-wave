## One farming objective and its reward. QuestLog feeds it kills and pickups.
class_name Quest
extends RefCounted

enum Kind { KILL, KILL_TYPE, KILL_ELITE, KILL_BOSS, COLLECT }
enum Reward { ITEM, RARE_ITEM, GOLD, LOOT_BONUS }

## Seconds a LOOT_BONUS reward lasts.
const LOOT_BONUS_TIME := 60.0

var kind := Kind.KILL
## The enemy a KILL_TYPE quest asks for.
var enemy: EnemyType
var required := 1
var progress := 0
var reward := Reward.ITEM
## Gold for GOLD, the multiplier bonus for LOOT_BONUS.
var reward_amount := 0.0


func is_done() -> bool:
	return progress >= required


func counts_kill(type: EnemyType) -> bool:
	match kind:
		Kind.KILL:
			return true
		Kind.KILL_TYPE:
			return type == enemy
		Kind.KILL_ELITE:
			return type.tier == EnemyType.Tier.ELITE
		Kind.KILL_BOSS:
			return type.tier == EnemyType.Tier.BOSS
	return false


func text() -> String:
	var goal := ""
	match kind:
		Kind.KILL:
			goal = "Slay %d foes" % required
		Kind.KILL_TYPE:
			goal = "Slay %d %ss" % [required, enemy.display_name]
		Kind.KILL_ELITE:
			goal = "Slay an elite"
		Kind.KILL_BOSS:
			goal = "Slay the boss"
		Kind.COLLECT:
			goal = "Collect %d gold" % required
	return "%s %d/%d" % [goal, mini(progress, required), required]


func reward_text() -> String:
	match reward:
		Reward.ITEM:
			return "Magic+ item"
		Reward.RARE_ITEM:
			return "Rare+ item"
		Reward.GOLD:
			return "%d gold" % reward_amount
	return "+%d%% loot for %ds" % [roundi(reward_amount * 100), LOOT_BONUS_TIME]
