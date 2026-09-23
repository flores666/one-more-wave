## The in-world HUD. Panels get the run, quests and player handed over here instead of finding them.
class_name Hud
extends UiLayer

@onready var _banner: Label = $Root/Banner
@onready var _gold: Label = $Root/Gold/Row/Amount


func setup(run: Run, quests: QuestLog, player: Player, athena: Athena, invasion: InvasionDirector) -> void:
	$Root/RunPanel.setup(run, invasion)
	$Root/Modifiers.setup(run)
	$Root/QuestTracker.setup(quests)
	$Root/Pointer.setup(run, athena, invasion)
	$Root/Inventory.setup(player)
	$Root/Choice.setup(run)
	$Root/GameOver.setup(run)
	run.gold_changed.connect(func() -> void: _gold.text = str(run.gold))


## A message across the top of the screen that fades after a moment.
func banner(message: String, color: Color) -> void:
	_banner.text = message
	_banner.self_modulate = color
	var tween := _banner.create_tween()
	tween.tween_property(_banner, "modulate:a", 1.0, 0.15).from(0.0)
	tween.tween_interval(2.5)
	tween.tween_property(_banner, "modulate:a", 0.0, 0.6)
