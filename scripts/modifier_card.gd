## One offered enemy modifier in the post-wave choice: press it to take the curse.
extends Button

@onready var _title: Label = $Margin/Box/Title
@onready var _description: Label = $Margin/Box/Description
@onready var _loot: Label = $Margin/Box/Loot


func show_modifier(number: int, modifier: EnemyModifier, owned: int) -> void:
	_title.text = "%d. %s" % [number, modifier.title] + (" (x%d)" % owned if owned > 0 else "")
	_description.text = modifier.description
	_loot.text = "+%d%% loot" % roundi(modifier.loot_bonus * 100)
