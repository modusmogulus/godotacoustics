extends Node

var sim_timer: Timer = $SimulationTimer


func start_simulation():
	
	PhysicsServer3D.set_active(true)
	sim_timer.start()
	
func stop_simulation():
	sim_timer.stop()
	PhysicsServer3D.set_active(false)

func set_sim_duration(duration: float):
	sim_timer.wait_time = duration
	
func get_sim_duration() -> float:
	return sim_timer.wait_time


func _on_simulation_timer_timeout() -> void:
	stop_simulation()
