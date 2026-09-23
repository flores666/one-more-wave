## HUD character sheet: the class, its primary stats and the combat numbers they give.
## Level and experience are on the portrait and the experience bar.
extends PanelContainer

@export var player: Player

@onready var _title: Label = $Box/Title
## Name labels of the primary stats, by CharacterStats key.
@onready var _stat_names: Dictionary[String, Label] = {
	"str": %Str, "agi": %Agi, "int": %Int, "luk": %Luk,
}


func _ready() -> void:
	_title.text = player.player_class.display_name
	# the stat that scales this class's damage stands out
	_stat_names[player.player_class.main_stat].theme_type_variation = &"TitleLabel"
	player.stats.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var s := player.stats
	%StrValue.text = str(s.get_stat("str"))
	%AgiValue.text = str(s.get_stat("agi"))
	%IntValue.text = str(s.get_stat("int"))
	%LukValue.text = str(s.get_stat("luk"))
	%DmgValue.text = "%.1f" % s.damage()
	%ApsValue.text = "%.2f" % (1.0 / s.cooldown())
	%CritValue.text = "%d%%" % roundi(s.crit_chance() * 100)
	%CdmgValue.text = "%d%%" % roundi(s.crit_multiplier() * 100)
	%MoveValue.text = "%d%%" % roundi(s.move_speed() * 100)
