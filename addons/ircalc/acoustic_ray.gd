extends RayCast3D

var history_index: int = 0
var ray_distance = 1000.0
#0 for initial ray, 1 for the first reflection
#2 for the second, 3 for third...
func _ready() -> void:
	target_position = Vector3(0.0, ray_distance, 0.0)
