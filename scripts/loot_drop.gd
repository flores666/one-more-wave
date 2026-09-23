## An item or a pile of gold lying on the ground until the player walks over it.
## Items show as a gem in their rarity colour; rare and epic ones cast a beam so they read from afar.
class_name LootDrop
extends Area2D

signal touched(drop: LootDrop)

## Drops scatter from the body and cannot be picked up mid-flight.
@export var scatter := 10.0
@export var scatter_time := 0.35

## Exactly one of these is set.
var item: Item
var gold := 0

@onready var _coin: Sprite2D = $Coin
@onready var _gem: Node2D = $Gem


func _ready() -> void:
	_coin.visible = item == null
	_gem.visible = item != null
	if item:
		var color := item.color()
		$Gem/Body.color = color
		$Gem/Outline.default_color = color.darkened(0.6)
		$Gem/Beam.default_color = color
		$Gem/Beam.visible = item.rarity >= Item.Rarity.RARE
	var to := position + Vector2.from_angle(randf() * TAU) * randf_range(0.3, 1.0) * scatter
	var tween := create_tween()
	tween.tween_property(self, "position", to, scatter_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(set_deferred.bind("monitoring", true))


func _on_body_entered(_body: Node2D) -> void:
	touched.emit(self)
