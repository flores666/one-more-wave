## An equipment slot in the gear panel: its name and the item worn there, or a dash.
extends HBoxContainer

@onready var item_button: ItemButton = $Item
@onready var _name: Label = $Name
@onready var _empty: Label = $Empty


func show_slot(slot_name: String, item: Item) -> void:
	_name.text = slot_name
	item_button.visible = item != null
	_empty.visible = item == null
	if item:
		item_button.show_item(item)
