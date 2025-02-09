extends Control


func _on_duration_spin_box_value_changed(value: float) -> void:
	IRCalcGlobalScene.set_sim_duration(value)
