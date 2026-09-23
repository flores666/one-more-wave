## Adds some of one enemy to matching waves: from first_wave, every `every` waves, up to last_wave (0 = no end).
class_name WaveRule
extends Resource

@export var enemy: EnemyType
@export var first_wave := 1
@export var every := 1
@export var last_wave := 0
@export var count := 1.0
## Extra enemies for every wave past first_wave; fractions accumulate.
@export var count_per_wave := 0.0


func count_for(wave: int) -> int:
	if wave < first_wave or (last_wave > 0 and wave > last_wave) or (wave - first_wave) % every != 0:
		return 0
	return floori(count + count_per_wave * (wave - first_wave))
