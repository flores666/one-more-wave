## A dev-tools row that steps one character value down or up; shift-click steps by big_step.
class_name StatStepper
extends HBoxContainer

signal stepped(key: String, amount: int)

## "level" or one of CharacterStats.STATS.
@export var key := ""
@export var label := ""
@export var big_step := 10

@onready var _value: Label = $Value


func _ready() -> void:
	$Name.text = label


func show_value(value: int) -> void:
	_value.text = str(value)


func _on_minus_pressed() -> void:
	stepped.emit(key, -_step())


func _on_plus_pressed() -> void:
	stepped.emit(key, _step())


func _step() -> int:
	return big_step if Input.is_key_pressed(KEY_SHIFT) else 1
