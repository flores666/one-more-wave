## The prototype world and the composition root of the defend-and-farm loop: creates the Run and
## hands it, and every other dependency, to the nodes that need it. The rules live in Run, QuestLog
## and Loot; this script routes events between them and the scene (drops, rewards, banners).
extends Node2D

const GOLD_COLOR := Color(1, 0.82, 0.25)
const DANGER_COLOR := Color(1, 0.4, 0.35)

@export var config: RunConfig
@export var entities: Node2D
@export var player: Player
@export var athena: Athena
@export var elder: Node
@export var spawner: EnemySpawner
@export var invasion: InvasionDirector
## FarmZone children.
@export var farm_zones: Node2D
@export var hud: Hud

var run: Run
var quests := QuestLog.new()


func _ready() -> void:
	run = Run.new(config)
	run.rng.randomize()
	athena.setup(run)
	elder.setup(run)
	spawner.run = run
	invasion.run = run
	for zone: FarmZone in farm_zones.get_children():
		zone.run = run
		for type in zone.enemies:
			if type not in quests.farm_types:
				quests.farm_types.append(type)
	hud.setup(run, quests, player, athena, invasion)
	run.phase_changed.connect(_on_phase_changed)
	invasion.cleared.connect(run.invasion_cleared)
	spawner.died.connect(_on_enemy_died)
	quests.completed.connect(_on_quest_completed)
	player.died.connect(func() -> void:
		hud.banner("You fell! Back at Athena in %ds" % Player.RESPAWN_TIME, DANGER_COLOR))
	player.teleport_interrupted.connect(func() -> void:
		FloatingText.spawn(entities, player.global_position + Vector2(0, -24), "Interrupted!", DANGER_COLOR))
	_on_phase_changed(run.phase)


func _process(delta: float) -> void:
	run.advance(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/class_select.tscn")


func _on_phase_changed(phase: Run.Phase) -> void:
	get_tree().paused = phase in [Run.Phase.MODIFIER_SELECTION, Run.Phase.DEFEAT]
	match phase:
		Run.Phase.FARMING:
			var boss := false
			for zone: FarmZone in farm_zones.get_children():
				zone.start_farming()
				boss = boss or zone.has_boss()
			quests.boss_available = boss
			quests.refill(run.wave, run.rng)
			hud.banner("Wave %d arrives in %ds. Go farm!" % [run.wave, ceili(run.time_left)], GOLD_COLOR)
		Run.Phase.INVASION:
			invasion.start()
			hud.banner("INVASION! Defend Athena!", DANGER_COLOR)
		Run.Phase.WAVE_COMPLETED:
			player.heal_full()
			hud.banner("Wave cleared!", GOLD_COLOR)


func _on_enemy_died(enemy: Enemy) -> void:
	player.stats.add_experience(enemy.stats.experience)
	quests.report_kill(enemy.stats.type, run.wave, run.rng)
	var drops := Loot.drops_for(enemy.stats, run, run.rng)
	# deaths arrive mid physics step, when new areas cannot be added
	for item: Item in drops.items:
		_drop.call_deferred(enemy.global_position, item, 0)
	if drops.gold > 0:
		_drop.call_deferred(enemy.global_position, null, drops.gold)


func _drop(at: Vector2, item: Item, gold: int) -> void:
	var drop := LootDrop.new()
	drop.item = item
	drop.gold = gold
	drop.position = at
	drop.touched.connect(_on_loot_touched)
	entities.add_child(drop)


func _on_loot_touched(drop: LootDrop) -> void:
	var above := player.global_position + Vector2(0, -20)
	if drop.item:
		if player.stats.inventory.add(drop.item):
			FloatingText.spawn(entities, above, drop.item.title(), drop.item.color())
		else:
			var value := Loot.salvage_value(drop.item)
			run.add_gold(value)
			FloatingText.spawn(entities, above, "Bag full: salvaged +%dg" % value, GOLD_COLOR)
	else:
		run.add_gold(drop.gold)
		quests.report_collect(drop.gold, run.wave, run.rng)
		FloatingText.spawn(entities, above, "+%dg" % drop.gold, GOLD_COLOR)
	drop.queue_free()


func _on_quest_completed(quest: Quest) -> void:
	hud.banner("Quest complete! %s" % quest.reward_text(), GOLD_COLOR)
	var quality := Loot.quality_for(run)
	match quest.reward:
		Quest.Reward.ITEM:
			_drop.call_deferred(player.global_position, Loot.roll(run.wave + 1, quality, run.rng, -1, Item.Rarity.MAGIC), 0)
		Quest.Reward.RARE_ITEM:
			_drop.call_deferred(player.global_position, Loot.roll(run.wave + 2, quality + 1.0, run.rng, -1, Item.Rarity.RARE), 0)
		Quest.Reward.GOLD:
			run.add_gold(roundi(quest.reward_amount))
		Quest.Reward.LOOT_BONUS:
			run.add_loot_bonus(quest.reward_amount, Quest.LOOT_BONUS_TIME)
