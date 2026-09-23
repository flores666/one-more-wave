extends StaticBody2D

const FLASH := 0.6
## Sway in pixels per point of damage, so crits and heavy hits shake harder.
const SHAKE_PER_DAMAGE := 0.1
const MAX_SHAKE := 4.0
const HIT_TIME := 0.25
const CRIT_TIME := 0.6
const CRIT_RISE := 6.0
## DPS covers the current burst of hits; a pause this long starts a new measurement.
const RESET_AFTER := 3.0

var _burst_damage := 0.0
var _burst_start := 0.0
var _last_hit := -INF
var _tween: Tween
var _crit_tween: Tween

@onready var _material: ShaderMaterial = $Sprite2D.material
@onready var _dps_label: Label = $DpsLabel
@onready var _crit_label: Label = $CritLabel
@onready var _crit_top := _crit_label.position.y


func _ready() -> void:
	$Hurtbox.hit.connect(_on_hit)


func _process(_delta: float) -> void:
	var now := _now()
	var dps := 0.0
	if now - _last_hit < RESET_AFTER:
		dps = _burst_damage / maxf(now - _burst_start, 1.0)
	_dps_label.text = "DPS %.1f" % dps


func _on_hit(damage: float, crit: bool) -> void:
	var now := _now()
	if now - _last_hit >= RESET_AFTER:
		_burst_damage = 0.0
		_burst_start = now
	_burst_damage += damage
	_last_hit = now

	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(_material, "shader_parameter/flash", 0.0, HIT_TIME).from(FLASH)
	_tween.tween_property(_material, "shader_parameter/shake", 0.0, HIT_TIME).from(minf(damage * SHAKE_PER_DAMAGE, MAX_SHAKE))
	if crit:
		_show_crit()


## "CRIT" pops in above the DPS readout, drifts up and fades.
func _show_crit() -> void:
	if _crit_tween:
		_crit_tween.kill()
	_crit_tween = create_tween().set_parallel()
	_crit_tween.tween_property(_crit_label, "position:y", _crit_top - CRIT_RISE, CRIT_TIME).from(_crit_top)
	_crit_tween.tween_property(_crit_label, "modulate:a", 0.0, CRIT_TIME).from(1.0).set_ease(Tween.EASE_IN)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
