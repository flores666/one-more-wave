class_name PlayerClass
extends Resource

@export var display_name := ""
@export_multiline var description := ""
## Scene spawned at the character's chest, rotated toward the aim direction.
@export var attack_scene: PackedScene
## Shown in the first hotbar slot.
@export var icon: Texture2D
## Seconds between attacks before attack speed.
@export var cooldown := 0.5
## Damage per hit before the main stat scales it.
@export var base_damage := 10.0
## The primary stat that scales this class's damage.
@export_enum("str", "agi", "int", "luk") var main_stat := "str"
## Primary stats at level 1, keyed by CharacterStats.STATS.
@export var base_stats: Dictionary[String, int] = {}
## Primary stats gained on every level up.
@export var stats_per_level: Dictionary[String, int] = {}
