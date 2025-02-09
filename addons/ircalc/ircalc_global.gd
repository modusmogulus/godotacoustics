@tool
extends Node

var sim_timer
var pressurefields = []
var soundspeed: float = 343 #m/s
func set_sim_timer(timer: Timer):
	sim_timer = timer
	
func start_simulation():
	PhysicsServer3D.set_active(true)
	sim_timer.start()
	
func stop_simulation():
	sim_timer.stop()
	PhysicsServer3D.set_active(false)

func set_sim_duration(duration: float):
	sim_timer.wait_time = duration
	
func get_sim_duration() -> float:
	return sim_timer.time_left

func _on_simulation_timer_timeout() -> void:
	stop_simulation()

func register_pressure_field(field_instance):
	pressurefields.append(field_instance)
	print(str(pressurefields))
	
func unregister_pressure_field(field_instance):
	pressurefields.erase(field_instance)
	print(str(pressurefields))
