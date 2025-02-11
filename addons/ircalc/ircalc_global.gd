@tool
extends Node

var sim_timer
var pressurefields = []
var emitters = []
var ac_listeners = []
var waveguides = []
var soften_diffuse: float = 10.0
var soundspeed: float = 343.0 #m/s
var emitter_count = 16
var optimize_wave: bool = false
var time_scale = 1.0

func user_req_prepare():
	for ac_em in emitters:
		ac_em.create_pfields(emitter_count)

func set_sim_timer(timer: Timer):
	sim_timer = timer

func set_time_scale(multiplier: float):
	time_scale = multiplier

func set_soften_diffuse(amount: float):
	soften_diffuse = amount

func set_optimize_wave(val: bool):
	optimize_wave = val
	
func get_optimize_wave() -> bool:
	return optimize_wave
	
func set_emitter_count(count: int):
	emitter_count = count
	
func get_emitter_count() -> int:
	return emitter_count
	
func set_soundspeed(val: int):
	soundspeed = val

func update_waveguides():
	var ar_pfpos: PackedVector3Array
	var ar_pfnm: PackedVector3Array
	ar_pfpos.clear()
	ar_pfnm.clear()
	
	for pf in pressurefields:
		ar_pfpos.append(pf.global_position)
		ar_pfnm.append(pf.velocity)
	for wvg in waveguides:
		if ar_pfpos.size() > 0:
			wvg.add_verts(ar_pfpos, ar_pfnm)

func start_simulation():
	
	PhysicsServer3D.set_active(true)
	for lis in ac_listeners:
		lis.start_rec()
	#for ac_em in emitters:
	#	ac_em.create_pfields(emitter_count)
	for pf in pressurefields:
		pf.set_simulating(true)
	
	
	#sim_timer.start()
	
func stop_simulation():
	#sim_timer.stop()
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
	#print(str(pressurefields))
	
func unregister_pressure_field(field_instance):
	pressurefields.erase(field_instance)
	#print(str(pressurefields))

func register_waveguide(wvg):
	waveguides.append(wvg)

func unregister_waveguide(wvg):
	waveguides.erase(wvg)

func register_acoustic_emitter(ac_em):
	emitters.append(ac_em)
	#print(str(ac_em))
	
func register_listener(lis):
	ac_listeners.append(lis)
	#print(str(ac_listeners))

func unregister_listener(lis):
	ac_listeners.erase(lis)
	#print(str(ac_listeners))

func unregister_acoustic_emitter(ac_em):
	emitters.erase(ac_em)
	#print(str(emitters))

func _ready() -> void:
	start_simulation()
