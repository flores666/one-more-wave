## Headless smoke test of the defend-and-farm loop, driving the real world scene:
##   godot --headless --path game --fixed-fps 60 res://tests/loop_smoke_test.tscn
## Exits with code 1 and prints FAIL lines if any check fails.
extends Node

var _failures := 0
var _world: Node2D


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_check_wave_table()
	_world = load("res://scenes/world.tscn").instantiate()
	_world.get_node("Entities/Player").player_class = load("res://resources/warrior.tres")
	get_tree().root.add_child(_world)
	await _frames(10)
	var run: Run = _world.run
	var player: Player = _world.player
	_check(run.phase == Run.Phase.FARMING and run.wave == 1, "starts farming wave 1")
	_check(_enemies().size() >= 20, "farm zones spawned monsters (%d)" % _enemies().size())
	_check(_world.quests.quests.size() == QuestLog.ACTIVE, "three quests active")

	# teleport: interrupted by damage, completes when left alone
	# a quiet spot, away from the farm zones, so no monster breaks the cast
	player.global_position = Vector2(60, 200)
	player._teleport = 0.0
	player.take_damage(1.0)
	_check(not player.is_teleporting(), "damage interrupts the teleport")
	player._teleport = 0.0
	await _seconds(Player.TELEPORT_TIME + 0.2)
	_check(player.global_position.distance_to(_world.athena.arrival_point()) < 2.0, "teleport lands at Athena")

	# invasion: invaders spawn at the edge and walk towards Athena
	run.call_invasion()
	await _seconds(1.0)
	var invaders := _enemies().filter(func(e: Enemy) -> bool: return e.is_invader())
	_check(invaders.size() > 0, "invasion spawned invaders")
	var start_distance: float = invaders[0].global_position.distance_to(_world.athena.global_position)
	_check(start_distance > 250.0, "invaders enter far from Athena (%d px)" % start_distance)
	await _seconds(2.0)
	if is_instance_valid(invaders[0]):
		_check(invaders[0].global_position.distance_to(_world.athena.global_position) < start_distance, "invaders march on Athena")

	# kill every invader the way the player's attacks do, until the wave clears
	var drops_before := _drops().size()
	for i in 600:
		for enemy in _enemies():
			if enemy.is_invader():
				enemy.get_node("Hurtbox").receive(9999.0, false)
		await _frames(1)
		if run.phase != Run.Phase.INVASION:
			break
	_check(run.phase == Run.Phase.WAVE_COMPLETED and run.wave == 2, "clearing the invasion completes the wave")
	_check(_drops().size() > drops_before, "kills dropped loot (%d drops)" % (_drops().size() - drops_before))

	# loot: pick everything up, equip a bag item if there is one, get stronger
	var damage_before := player.stats.damage()
	var hp_before := player.stats.max_hp()
	var weapon := Loot.roll(5, 2.0, run.rng, Item.Slot.WEAPON, Item.Rarity.EPIC)
	_world._drop(player.global_position, weapon, 0)
	for drop in _drops():
		_world._on_loot_touched(drop)
	var inventory := player.stats.inventory
	_check(inventory.equipped.size() > 0, "picked up gear is worn (%d slots)" % inventory.equipped.size())
	if inventory.bag.has(weapon):
		inventory.equip(weapon)
	_check(inventory.equipped[Item.Slot.WEAPON] == weapon, "an epic weapon can be equipped")
	_check(player.stats.damage() > damage_before or player.stats.max_hp() > hp_before, "gear makes the player stronger (%.1f -> %.1f dmg)" % [damage_before, player.stats.damage()])
	_check(run.gold > 0, "gold collected (%d)" % run.gold)

	# modifier choice pauses the game, applies to new enemies and raises loot
	await _seconds(run.config.wave_cleared_delay + 0.2)
	_check(run.phase == Run.Phase.MODIFIER_SELECTION and get_tree().paused, "modifier selection pauses the game")
	_check(run.choices.size() == 3, "three modifier cards offered")
	var vigor: EnemyModifier = run.config.modifiers.filter(func(m: EnemyModifier) -> bool: return m.title == "Vigor")[0]
	run.choices[0] = vigor
	var grunt: EnemyType = load("res://resources/enemies/grunt.tres")
	var hp_plain := EnemyStats.build(grunt, run).max_hp
	var loot_before := run.loot_multiplier()
	run.choose(0)
	_check(run.phase == Run.Phase.FARMING and not get_tree().paused, "picking a card starts farming again")
	_check(is_equal_approx(EnemyStats.build(grunt, run).max_hp, hp_plain * 1.2), "Vigor gives +20% enemy health")
	_check(is_equal_approx(run.loot_multiplier(), loot_before + vigor.loot_bonus), "Vigor raises the loot multiplier")
	_check(is_equal_approx(run.time_left, run.config.farming_duration), "farming timer restarts")

	# behaviour modifiers: split and explode
	var mitosis: EnemyModifier = run.config.modifiers.filter(func(m: EnemyModifier) -> bool: return m.title == "Mitosis")[0]
	run.modifiers.append(mitosis)
	var splitter: Enemy = _world.spawner.spawn(grunt, Vector2(200, 200), false)
	await _frames(2)
	var count := _enemies().size()
	splitter.get_node("Hurtbox").receive(9999.0, false)
	await _frames(3)
	_check(_enemies().size() == count + 1, "Mitosis splits a dead grunt in two")

	# defeat
	run.damage_base(99999.0)
	await _frames(2)
	_check(run.phase == Run.Phase.DEFEAT and get_tree().paused, "Athena at zero health ends the run")
	_check(_world.get_node("Hud/Root/GameOver").visible, "game over screen shows")

	print("smoke test: %s" % ("PASS" if _failures == 0 else "%d FAILED" % _failures))
	get_tree().quit(1 if _failures else 0)


func _check_wave_table() -> void:
	var table: WaveTable = load("res://resources/run_config.tres").waves
	var summary: Array[String] = []
	for wave in [1, 4, 5, 10, 25, 50, 100]:
		var tiers := [0, 0, 0]
		for type in table.compose(wave):
			tiers[type.tier] += 1
		summary.append("w%d:%d/%d/%d" % [wave, tiers[0], tiers[1], tiers[2]])
	print("wave composition (normal/elite/boss): ", " ".join(summary))
	_check(table.compose(4).all(func(t: EnemyType) -> bool: return t.tier == EnemyType.Tier.NORMAL), "waves 1-4 are basic")
	_check(table.compose(5).any(func(t: EnemyType) -> bool: return t.tier == EnemyType.Tier.ELITE), "wave 5 has an elite")
	_check(table.compose(10).any(func(t: EnemyType) -> bool: return t.tier == EnemyType.Tier.BOSS), "wave 10 has a boss")
	_check(table.compose(100).size() > table.compose(10).size(), "wave 100 is bigger than wave 10")


func _enemies() -> Array:
	return _world.entities.get_children().filter(func(n: Node) -> bool: return n is Enemy and not n.is_queued_for_deletion())


func _drops() -> Array:
	return _world.entities.get_children().filter(func(n: Node) -> bool: return n is LootDrop and not n.is_queued_for_deletion())


func _check(ok: bool, what: String) -> void:
	print(("  ok   " if ok else "  FAIL ") + what)
	if not ok:
		_failures += 1


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _seconds(t: float) -> void:
	await _frames(ceili(t * 60))
