extends UiLayer

const WORLD := preload("res://scenes/world.tscn")

@export var classes: Array[PlayerClass] = []

@onready var _box: VBoxContainer = $Root/Center/Panel/Box
@onready var _description: Label = $Root/Center/Panel/Box/Description


func _ready() -> void:
	super()
	var buttons: Array[Button] = []
	for player_class in classes:
		var button := Button.new()
		button.text = player_class.display_name
		button.pressed.connect(_start.bind(player_class))
		button.focus_entered.connect(func() -> void: _description.text = player_class.description)
		button.mouse_entered.connect(button.grab_focus)
		_box.add_child(button)
		_box.move_child(button, _description.get_index())
		buttons.append(button)
	buttons[0].grab_focus()


func _start(player_class: PlayerClass) -> void:
	var world := WORLD.instantiate()
	world.get_node("Entities/Player").player_class = player_class
	get_tree().change_scene_to_node(world)
