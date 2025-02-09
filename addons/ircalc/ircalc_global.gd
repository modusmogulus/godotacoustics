@tool
extends Node

var sim_timer
var pressurefields = []
var emitters = []
var soundspeed: float = 1/343 #m/s
var emitter_count = 16

func user_req_prepare():
	for ac_em in emitters:
		ac_em.create_pfields(emitter_count)

func set_sim_timer(timer: Timer):
	sim_timer = timer

func set_emitter_count(count: int):
	emitter_count = count
	
func get_emitter_count() -> int:
	return emitter_count

func start_simulation():
	for ac_em in emitters:
		ac_em.create_pfields(emitter_count)
	for pf in pressurefields:
		pf.set_simulating(true)
	PhysicsServer3D.set_active(true)
	sim_timer.start()
	
func stop_simulation():
	sim_timer.stop()
	PhysicsServer3D.set_active(false)
	for pf in pressurefields:
		pf.set_simulating(false)
		pf.queue_free()

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
	
func register_acoustic_emitter(ac_em):
	emitters.append(ac_em)
	print(str(ac_em))
	
func unregister_acoustic_emitter(ac_em):
	emitters.erase(ac_em)
	print(str(emitters))
	
