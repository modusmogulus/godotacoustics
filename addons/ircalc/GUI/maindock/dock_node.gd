@tool
extends Control

func _on_button_start_sim_pressed() -> void:
	_start_the_sim()

#func _ready() -> void:
#	_start_the_sim() #for playmode
	
func _start_the_sim() -> void:
	IRCalcGlobalScene.sim_timer = $Timer
	IRCalcGlobalScene.set_emitter_count(floor($HBoxContainer/Handles/CountSpin.value))
	IRCalcGlobalScene.set_sim_duration($HBoxContainer/Handles/DurationSpin.value)
	IRCalcGlobalScene.set_soften_diffuse($HBoxContainer/Handles/DiffuseSpin.value)
	IRCalcGlobalScene.set_soundspeed($SpeedSpin.value)
	IRCalcGlobalScene.set_time_scale($TimeScaleSlider.value * 0.01)
	IRCalcGlobalScene.start_simulation()
	
	
func _process(delta: float) -> void:
	if IRCalcGlobalScene.sim_timer && IRCalcGlobalScene.get_sim_duration() != 0:
		$StateLabel.text = str(IRCalcGlobalScene.get_sim_duration())


func _on_button_stop_sim_pressed() -> void:
	IRCalcGlobalScene.stop_simulation()


func _on_button_spawn_pressed() -> void:
	IRCalcGlobalScene.user_req_prepare()


func _on_optimize_check_box_toggled(toggled_on: bool) -> void:
	IRCalcGlobalScene.set_optimize_wave(toggled_on)


func _on_button_play_ir_pressed() -> void:
	IRCalcGlobalScene.play_ir()
