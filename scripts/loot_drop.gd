## An item or a pile of gold lying on the ground until the player walks over it.
class_name LootDrop
extends Area2D

signal touched(drop: LootDrop)

const COIN := preload("res://assets/ui/ui_skin.png")
const COIN_REGION := Rect2(34, 18, 7, 9)
## Drops scatter from the body and cannot be picked up mid-flight.
const SCATTER := 10.0
const SCATTER_TIME := 0.35

## Exactly one of these is set.
var item: Item
var gold := 0
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4  # the player
	monitoring = false
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 7.0
	add_child(shape)
	if gold > 0:
		var coin := Sprite2D.new()
		coin.texture = AtlasTexture.new()
		coin.texture.atlas = COIN
		coin.texture.region = COIN_REGION
		coin.scale = Vector2.ONE * 0.6
		coin.offset.y = -4
		add_child(coin)
	body_entered.connect(func(_body: Node2D) -> void: touched.emit(self))
	var to := position + Vector2.from_angle(randf() * TAU) * randf_range(0.3, 1.0) * SCATTER
	var tween := create_tween()
	tween.tween_property(self, "position", to, SCATTER_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(set_deferred.bind("monitoring", true))


func _process(delta: float) -> void:
	_t += delta
	if item:
		queue_redraw()


## Items are gems in their rarity colour; rare and epic ones cast a beam so they read from afar.
func _draw() -> void:
	if not item:
		return
	var y := -4.0 + roundf(sin(_t * 3.0))
	var color := item.color()
	if item.rarity >= Item.Rarity.RARE:
		draw_rect(Rect2(-0.5, y - 24, 1, 24), Color(color, 0.35 + 0.15 * sin(_t * 4.0)))
	var gem := PackedVector2Array([Vector2(0, y - 3), Vector2(3, y), Vector2(0, y + 3), Vector2(-3, y)])
	draw_colored_polygon(gem, color)
	draw_polyline(gem + PackedVector2Array([gem[0]]), color.darkened(0.6), 1.0)
