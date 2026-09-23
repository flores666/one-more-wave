## The gear panel (I): equipped items, the bag, details of the hovered item compared with what is
## worn in its slot, and the character numbers the gear adds up to. Click a bag item to equip it.
extends PanelContainer

@export var slot_row_scene: PackedScene
@export var item_button_scene: PackedScene

var _player: Player

@onready var _equipped: VBoxContainer = $Columns/Left/Equipped
@onready var _bag: VBoxContainer = $Columns/Left/Bag
@onready var _bag_title: Label = $Columns/Left/BagTitle
@onready var _details: Label = $Columns/Right/Details
@onready var _totals: Label = $Columns/Right/Totals


func setup(player: Player) -> void:
	_player = player
	player.stats.changed.connect(_refresh)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = not visible
		_refresh()


func _refresh() -> void:
	if not visible:
		return
	var inventory := _player.stats.inventory
	for child in _equipped.get_children() + _bag.get_children():
		child.queue_free()
	for slot in Item.SLOT_NAMES.size():
		var row: Control = slot_row_scene.instantiate()
		_equipped.add_child(row)
		var item: Item = inventory.equipped.get(slot)
		row.show_slot(Item.SLOT_NAMES[slot], item)
		row.item_button.mouse_entered.connect(_show_details.bind(item))
	_bag_title.text = "BAG %d/%d" % [inventory.bag.size(), Inventory.BAG_SIZE]
	for item in inventory.bag:
		var button: ItemButton = item_button_scene.instantiate()
		_bag.add_child(button)
		button.show_item(item)
		button.mouse_entered.connect(_show_details.bind(item))
		button.pressed.connect(inventory.equip.bind(item))
	var s := _player.stats
	_totals.text = "DMG %.1f   APS %.2f\nCRIT %d%%   HP %d\nARM %d (-%d%% dmg)" % [
		s.damage(), 1.0 / s.cooldown(), roundi(s.crit_chance() * 100), roundi(s.max_hp()),
		roundi(s.armor()), roundi(100 * s.armor() / (s.armor() + CharacterStats.ARMOR_FACTOR))]


func _show_details(item: Item) -> void:
	var lines: PackedStringArray = ["%s (level %d)" % [item.title(), item.level]]
	for key in item.stats:
		lines.append(Item.format_stat(key, item.stats[key]))
	var worn: Item = _player.stats.inventory.equipped.get(item.slot)
	if worn and worn != item:
		lines.append("")
		lines.append("vs worn %s:" % worn.title())
		for key in Item.STATS:
			var diff := item.get_stat(key) - worn.get_stat(key)
			if not is_zero_approx(diff):
				lines.append("  " + Item.format_stat(key, diff))
	_details.text = "\n".join(lines)
	_details.self_modulate = item.color()
