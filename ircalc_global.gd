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
var runtime_gizmo: Gizmo3D
var rayhits: Array[AcousticRayHit]
var emitters_created: int = 0

func user_req_prepare():
	for pf in pressurefields:
		pf.queue_free()
	for ac_em in emitters:
		
		ac_em.create_pfields(emitter_count, ac_em.global_position)

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

func broadcast_inbetween_calculation():
	for lis in ac_listeners:
		lis.make_inbetweens()

func start_simulation():
	
	PhysicsServer3D.set_active(true)
	for lis in ac_listeners:
		lis.start_rec()
	#for ac_em in emitters:
	#	ac_em.create_pfields(emitter_count)
	for pf in pressurefields:
		pf.set_simulating(true)
		
	for ac_em in emitters:
		ac_em.is_optimizing = false
	
	
	#sim_timer.start()
	
func stop_simulation():
	#sim_timer.stop()
	PhysicsServer3D.set_active(false)
	for pf in pressurefields:
		pf.set_simulating(false)
	for ac_lis in ac_listeners:
		ac_lis.stop_rec()
	for ac_em in emitters:
		ac_em.set_currently_raytracing(false)
	for ac_em in emitters:
		ac_em.is_optimizing = false
	
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

func start_raytracing():
	for ac_em in emitters:
		ac_em.set_currently_raytracing(true)

func play_ir():
	for ac_lis in ac_listeners:
		ac_lis.play_recorded()
		
func f32_array_to_wav_file(buf: PackedFloat32Array, export_path: String):
	var data_size: int = buf.size() * 4  # 4 bytes per float (32-bit)
	var sample_rate: int = 44100  # Standard CD-quality sample rate
	var num_channels: int = 1     # Mono
	var byte_rate: int = sample_rate * num_channels * 4
	var block_align: int = num_channels * 4
	var bits_per_sample: int = 32

	var file_path := "res://ExportedAudio/%s%d.wav" % [export_path, randi_range(-4096, 4096)]
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to save WAV file: %s" % FileAccess.get_open_error())
		return
	
	# Write WAV header
	# RIFF chunk
	file.store_string("RIFF")                     # Chunk ID
	file.store_32(36 + data_size)                 # Chunk size
	file.store_string("WAVE")                     # Format

	# fmt subchunk
	file.store_string("fmt ")                     # Subchunk ID
	file.store_32(16)                             # Subchunk size (16 for PCM)
	file.store_16(3)                              # Audio format (3 = IEEE float)
	file.store_16(num_channels)                   # Num channels
	file.store_32(sample_rate)                    # Sample rate
	file.store_32(byte_rate)                      # Byte rate
	file.store_16(block_align)                    # Block align
	file.store_16(bits_per_sample)                # Bits per sample

	# data subchunk
	file.store_string("data")                     # Subchunk ID
	file.store_32(data_size)                      # Data size

	# Write audio data
	for sample in buf:
		file.store_float(sample)
		#file.store_float(lerppaLerp(abuf1))
		
	file.close()
	buf.clear()

func _ready() -> void:
	runtime_gizmo = Gizmo3D.new()
	#get_tree()
	$Gizmos.add_child(runtime_gizmo)
	#runtime_gizmo = Gizmo3D.new()
	#start_simulation()
