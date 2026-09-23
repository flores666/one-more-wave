## What the player carries: one equipped item per slot and a small bag of spares.
class_name Inventory
extends RefCounted

signal changed

const BAG_SIZE := 10

var equipped: Dictionary[int, Item] = {}
var bag: Array[Item] = []


func is_full() -> bool:
	return bag.size() >= BAG_SIZE


## Into an empty slot straight away, otherwise into the bag. False when there is no room.
func add(item: Item) -> bool:
	if not equipped.has(item.slot):
		equipped[item.slot] = item
	elif is_full():
		return false
	else:
		bag.append(item)
	changed.emit()
	return true


## Swaps a bag item with whatever is in its slot; the old item takes its place in the bag.
func equip(item: Item) -> void:
	var index := bag.find(item)
	assert(index >= 0)
	var old: Item = equipped.get(item.slot)
	equipped[item.slot] = item
	if old:
		bag[index] = old
	else:
		bag.remove_at(index)
	changed.emit()


func discard(item: Item) -> void:
	bag.erase(item)
	changed.emit()


func bonus(key: String) -> float:
	var total := 0.0
	for item: Item in equipped.values():
		total += item.get_stat(key)
	return total
