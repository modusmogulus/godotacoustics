@tool
extends AudioStreamPlayer3D


var abuf1: PackedFloat32Array = [] #virtual audio buffer
var time: float = 0.0
@export var export_path: String = "IMP_0"
@export var smoothingwindow: int = 512
#@export var buf: AudioStreamPlayer3D
var playback: AudioStreamGeneratorPlayback
var pr: float = 0.0 #pressure
var bitrate: int = 44100
var blocksize: int = 512
var recording: bool = false
var delta_time_in_samples: int
var needle: int = 0 #The "playhead" position when recording, like the needle in making LPs
var currentpressure: float = 0.0

func start_rec() -> void:
	
	needle = 0
	time = 0.0
	recording = true
	print("Recording...")

func sinc(x: float) -> float:
	if x == 0.0:
		return 1.0
	return sin(PI * x) / (PI * x)

# Whittaker-Shannon interpolation
func sinc_interpolate(samples: Array, x: float, kernel_size: int = 10) -> float:
	var result = 0.0
	var length = samples.size()

	for n in range(max(0, int(x) - kernel_size), min(length, int(x) + kernel_size)):
		result += samples[n] * sinc(x - n)
	return result

func stop_rec() -> void:
	stop()
	recording = false
	needle = 0
	#for i in abuf1.size():
	#	for j in range(0, smoothingwindow, 1):
	#		if abs(abuf1[i-j]) < abs(abuf1[i]):
	#			abuf1[i] = lerpf(abuf1[i], abuf1[i+j], j/smoothingwindow)
			
func _enter_tree() -> void:
	IRCalcGlobalScene.register_listener(self)
	

func  _exit_tree() -> void:
	IRCalcGlobalScene.unregister_listener(self)

func _on_ear_area_entered(area: Area3D) -> void:
	if !recording: return
	if "AcPressure" in area.get_groups():
		var pressure: float = area.get_meta("pressure")
		currentpressure = pressure
		abuf1.insert(needle, 1.0*pressure)
		needle += 1
		
func array_to_wav(ar: PackedByteArray) -> PackedByteArray:
	var data: PackedByteArray
	var size: int = ar.size()
	#==== HEADER ====
	data = ['R','I',
	'F','F', size, 'W','A','V','E','f','m','t']
	#		57, 41, 56, 45, 66, 6D, 74]
	
	return data
	
func construct_signal(ar: PackedFloat32Array) -> PackedFloat32Array:
	
	var p1: float = 0.5
	var p2: float = 0.5
	var current_index: int = 0
	var last_non_zero_index: int = 0
	var steps_between_them: int = 0
	var w: int = 0
	
	for i in ar.size()-1:
		if ar[i] != 0:
			last_non_zero_index = current_index
			p2 = ar[i]
			current_index = i
			steps_between_them = current_index - last_non_zero_index
			w = 0
			for j in range(last_non_zero_index, current_index, 1):
				w += 1
				var percentage: float = steps_between_them/w #in decimal 0-1
				ar[j] = lerpf(ar[last_non_zero_index], ar[current_index], 1/percentage)
	return ar
	
func play_recorded():
	print("Play requested")
	
	play(0.0)
	#fill_buffer(abuf1)
	recording = false
	#var pressure_16bit_l: PackedByteArray = abuf1.to_byte_array()
	randomize()
	var file = FileAccess.open("res://ExportedAudio/" + export_path + str(randi_range(-4096, 4096)),FileAccess.WRITE_READ)
	#for b in abuf1.size():
		#abuf1[b] = sinc_interpolate(abuf1, b, 10)
	#file.store_buffer(abuf1.to_byte_array())
	abuf1 = construct_signal(abuf1)
	for ar in abuf1:
		file.store_float(ar)
	#file.store_buffer(construct_signal(abuf1).to_byte_array())
	file.close()
	abuf1.clear()
	#wavfile.format = AudioStreamWAV.FORMAT_8_BITS
	#wavfile = wavfile.format()
	#var wavfile = AudioStreamWAV.new()
	#wavfile.load_from_buffer(array_to_wav(pressure_16bit_l))
	#wavfile.save_to_wav("usr://IMPULSSI01")
func _process(delta: float) -> void:
	#delta_time_in_samples = floor((bitrate * (0.00167*delta)) * IRCalcGlobalScene.time_scale)
	delta_time_in_samples = 60*IRCalcGlobalScene.time_scale
	while delta_time_in_samples > 0:
		#if needle >= abuf1.size():
		
		abuf1.append(0.0)
		#else:
		#	if abuf1[needle] != 0:
		#		abuf1.insert(needle+delta_time_in_samples, currentpressure) #padding the buffer with zeros
		needle += 1
		delta_time_in_samples -= 1


func _on_ear_area_exited(area: Area3D) -> void:
	if !recording: return
	if "AcPressure" in area.get_groups():
		var pressure: float = area.get_meta("pressure")
		currentpressure = pressure
		abuf1.insert(needle, -1.0*pressure)
		needle += 1
