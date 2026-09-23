extends UiLayer

@export var world_scene: PackedScene

@onready var _classes: VBoxContainer = $Root/Center/Panel/Box/Classes
@onready var _description: Label = $Root/Center/Panel/Box/Description


func _ready() -> void:
	super()
	for button: ClassButton in _classes.get_children():
		button.pressed.connect(_start.bind(button.player_class))
		button.focus_entered.connect(func() -> void: _description.text = button.player_class.description)
	_classes.get_child(0).grab_focus()


func _start(player_class: PlayerClass) -> void:
	var world := world_scene.instantiate()
	world.get_node("Entities/Player").player_class = player_class
	get_tree().change_scene_to_node(world)
