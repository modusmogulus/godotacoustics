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
	

func fill_buffer(ar: PackedVector2Array):
	needle = 0
	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		needle += 1
		playback.push_frame(ar[needle]) # Audio frames are stereo.
		to_fill -= 1
		
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
	
	
func play_recorded():
	print("Play requested")
	
	play(0.0)
	#fill_buffer(abuf1)
	recording = false
	#var pressure_16bit_l: PackedByteArray = abuf1.to_byte_array()
	randomize()
	var file = FileAccess.open("res://" + export_path + str(randi_range(-4096, 4096)),FileAccess.WRITE_READ)
	file.store_buffer(abuf1.to_byte_array())
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
		if needle >= abuf1.size():
			abuf1.append(0.0)
		#else:
			#if abuf1[needle] != 0:
				#abuf1.insert(needle+delta_time_in_samples, currentpressure) #padding the buffer with zeros
				#abuf1
		needle += 1
		delta_time_in_samples -= 1


func _on_ear_area_exited(area: Area3D) -> void:
	if !recording: return
	if "AcPressure" in area.get_groups():
		var pressure: float = area.get_meta("pressure")
		currentpressure = pressure
		abuf1.insert(needle, -1.0*pressure)
		needle += 1
