## The quests running during a run. Three are always active: a finished quest pays out through
## `completed` and a fresh one takes its place, scaled to the current wave.
class_name QuestLog
extends RefCounted

signal changed
signal completed(quest: Quest)

const ACTIVE := 3

var quests: Array[Quest] = []
## What the world currently offers, so quests only ask for enemies that can be found.
var farm_types: Array[EnemyType] = []
var boss_available := false


func refill(wave: int, rng: RandomNumberGenerator) -> void:
	while quests.size() < ACTIVE:
		quests.append(_generate(wave, rng))
	changed.emit()


func report_kill(type: EnemyType, wave: int, rng: RandomNumberGenerator) -> void:
	_advance(func(q: Quest) -> bool: return q.counts_kill(type), 1, wave, rng)


func report_collect(amount: int, wave: int, rng: RandomNumberGenerator) -> void:
	_advance(func(q: Quest) -> bool: return q.kind == Quest.Kind.COLLECT, amount, wave, rng)


func _advance(matches: Callable, amount: int, wave: int, rng: RandomNumberGenerator) -> void:
	var touched := false
	for quest in quests.duplicate():
		if not matches.call(quest):
			continue
		touched = true
		quest.progress += amount
		if quest.is_done():
			quests.erase(quest)
			completed.emit(quest)
	if touched:
		refill(wave, rng)


func _generate(wave: int, rng: RandomNumberGenerator) -> Quest:
	var kinds: Array[Quest.Kind] = [Quest.Kind.KILL, Quest.Kind.COLLECT, Quest.Kind.KILL_ELITE]
	if not farm_types.is_empty():
		kinds.append(Quest.Kind.KILL_TYPE)
	if boss_available:
		kinds.append(Quest.Kind.KILL_BOSS)
	# one of each kind at a time, so the three quests pull in different directions
	var taken := quests.map(func(q: Quest) -> Quest.Kind: return q.kind)
	var free := kinds.filter(func(k: Quest.Kind) -> bool: return k not in taken)
	var quest := Quest.new()
	var pool: Array = free if not free.is_empty() else kinds
	quest.kind = pool[rng.randi_range(0, pool.size() - 1)]
	match quest.kind:
		Quest.Kind.KILL:
			quest.required = 8 + wave
		Quest.Kind.KILL_TYPE:
			quest.enemy = farm_types[rng.randi_range(0, farm_types.size() - 1)]
			quest.required = 4 + wave / 2
		Quest.Kind.COLLECT:
			quest.required = 15 + 3 * wave
	quest.reward = rng.randi_range(0, Quest.Reward.size() - 1) as Quest.Reward
	if quest.kind in [Quest.Kind.KILL_ELITE, Quest.Kind.KILL_BOSS]:
		quest.reward = Quest.Reward.RARE_ITEM
	elif quest.kind == Quest.Kind.COLLECT and quest.reward == Quest.Reward.GOLD:
		quest.reward = Quest.Reward.ITEM
	match quest.reward:
		Quest.Reward.GOLD:
			quest.reward_amount = 20 + 5 * wave
		Quest.Reward.LOOT_BONUS:
			quest.reward_amount = 0.5
	return quest
