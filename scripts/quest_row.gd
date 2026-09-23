## One entry in the quest tracker: the objective with its progress, and the reward below it.
extends VBoxContainer

@onready var _objective: Label = $Objective/Text
@onready var _reward: Label = $Reward/Text


func show_quest(quest: Quest) -> void:
	_objective.text = quest.text()
	_reward.text = "> " + quest.reward_text()
