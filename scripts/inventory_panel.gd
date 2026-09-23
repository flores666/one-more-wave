## The gear panel (I): equipped items, the bag, details of the hovered item compared with what is
## worn in its slot, and the character numbers the gear adds up to. Click a bag item to equip it.
extends PanelContainer

const DETAILS_WIDTH := 110

var _player: Player
var _equipped := VBoxContainer.new()
var _bag := VBoxContainer.new()
var _bag_title := Label.new()
var _details := Label.new()
var _totals := Label.new()


func setup(player: Player) -> void:
	_player = player
	visible = false
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 8)
	add_child(columns)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 2)
	columns.add_child(left)
	left.add_child(_heading("EQUIPMENT  [I]"))
	left.add_child(_equipped)
	_bag_title.theme_type_variation = &"TitleLabel"
	left.add_child(_bag_title)
	left.add_child(_bag)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 4)
	columns.add_child(right)
	right.add_child(_heading("DETAILS"))
	_details.custom_minimum_size.x = DETAILS_WIDTH
	_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details.text = "Hover an item."
	right.add_child(_details)
	right.add_child(_heading("CHARACTER"))
	right.add_child(_totals)
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
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = Item.SLOT_NAMES[slot]
		name_label.theme_type_variation = &"HintLabel"
		name_label.custom_minimum_size.x = 30
		row.add_child(name_label)
		var item: Item = inventory.equipped.get(slot)
		if item:
			row.add_child(_item_button(item, false))
		else:
			var empty := Label.new()
			empty.text = "-"
			empty.theme_type_variation = &"HintLabel"
			row.add_child(empty)
		_equipped.add_child(row)
	_bag_title.text = "BAG %d/%d" % [inventory.bag.size(), Inventory.BAG_SIZE]
	for item in inventory.bag:
		_bag.add_child(_item_button(item, true))
	var s := _player.stats
	_totals.text = "DMG %.1f   APS %.2f\nCRIT %d%%   HP %d\nARM %d (-%d%% dmg)" % [
		s.damage(), 1.0 / s.cooldown(), roundi(s.crit_chance() * 100), roundi(s.max_hp()),
		roundi(s.armor()), roundi(100 * s.armor() / (s.armor() + CharacterStats.ARMOR_FACTOR))]


func _heading(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = &"TitleLabel"
	return label


func _item_button(item: Item, in_bag: bool) -> Button:
	var button := Button.new()
	button.text = "%s  L%d" % [item.title(), item.level]
	button.flat = true
	button.focus_mode = FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, item.color().lightened(0.3) if state != "font_color" else item.color())
	button.mouse_entered.connect(_show_details.bind(item))
	if in_bag:
		button.pressed.connect(_player.stats.inventory.equip.bind(item))
	return button


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
	_details.add_theme_color_override("font_color", item.color())
