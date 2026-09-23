## An item in the gear panel, written in its rarity colour.
class_name ItemButton
extends Button

var item: Item


func show_item(value: Item) -> void:
	item = value
	text = "%s  L%d" % [item.title(), item.level]
	self_modulate = item.color()
