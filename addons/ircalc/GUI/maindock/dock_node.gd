@tool
extends Control

func _on_button_start_sim_pressed() -> void:
	
	IRCalcGlobalScene.sim_timer = $Timer
	IRCalcGlobalScene.set_emitter_count(floor($HBoxContainer/Handles/CountSpin.value))
	IRCalcGlobalScene.set_sim_duration($HBoxContainer/Handles/DurationSpin.value)
	IRCalcGlobalScene.set_soften_diffuse($HBoxContainer/Handles/DiffuseSpin.value)
	IRCalcGlobalScene.start_simulation()
	
func _process(delta: float) -> void:
	if IRCalcGlobalScene.sim_timer && IRCalcGlobalScene.get_sim_duration() != 0:
		$StateLabel.text = str(IRCalcGlobalScene.get_sim_duration())


func _on_button_stop_sim_pressed() -> void:
	IRCalcGlobalScene.stop_simulation()


func _on_button_spawn_pressed() -> void:
	IRCalcGlobalScene.user_req_prepare()
