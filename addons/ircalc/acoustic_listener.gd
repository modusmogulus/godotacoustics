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
var previouspressure: float = 0.0
var waveform: PackedFloat32Array = [0.0, 0.01, 0.05, 0.1, 0.25, 0.45, 0.5, 0.45, 0.25, 0.1, 0.05, 0.01, 0.0]
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
func buffer_to_chunk(buffer: PackedFloat32Array, index: int, chunk_size: int) -> PackedFloat32Array:
	chunk_size = floor(chunk_size*0.5)
	var returnbuf: PackedFloat32Array
	if index+chunk_size >= buffer.size():
		buffer.slice(index-chunk_size, buffer.size())
	elif index-chunk_size <= 0:
		buffer.slice(0, index+chunk_size)
	else:
		buffer.slice(index-chunk_size, index+chunk_size)
	return returnbuf

func make_inbetweens() -> void:
	#for i in abuf1.size():
	#	abuf1[i] = lerppaLerp(buffer_to_chunk(abuf1, i, 32))
	pass

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
		if abuf1[needle-2] != pressure: previouspressure = pressure
		#for i in waveform.size():
		#	if needle > waveform.size() + abuf1.size():
		#		abuf1.insert(needle+i, waveform[i]*pressure)
		#	else:
		#		abuf1.insert((needle+i) - floor(waveform.size()*0.5), pressure * (abuf1[i] + waveform[i])) #sum of waves if they overlap
		
		abuf1[needle-1] = pressure
		#needle += 1
		
func array_to_wav(ar: PackedByteArray) -> PackedByteArray:
	var data: PackedByteArray
	var size: int = ar.size()
	#==== HEADER ====
	data = ['R','I',
	'F','F', size, 'W','A','V','E','f','m','t']
	#		57, 41, 56, 45, 66, 6D, 74]
	
	return data

func fix_k(length: int, firstValue: float, lastValue: float, index: int) -> float:
	#solved by lerppa
	var a_or_b: float
	var k: float
	if firstValue > 0:
		a_or_b = firstValue
	else:
		a_or_b = 0
	k = ((abs(lastValue - firstValue) / length) * index + a_or_b)
	return k
	
func construct_signal(ar: PackedFloat32Array) -> PackedFloat32Array:
	
	var p1: float = 0.5
	var p2: float = 0.5
	var current_index: int = 0
	var last_non_zero_index: int = 0
	var steps_between_them: int = 0
	var w: float = 0
	
	for i in ar.size()-1:
		last_non_zero_index = current_index
		p2 = ar[i]
		current_index = i
		steps_between_them = current_index - last_non_zero_index
		ar[i] = fix_k(steps_between_them, last_non_zero_index, current_index, i)
	return ar
	

func calculate(length: int, firstValue: float, lastValue: float, index: int) -> float:
	if (absf(lastValue - firstValue) / length) * index + firstValue> 0:
		return firstValue 
	else:
		return 0
	
func lerppaLerp(arr1: PackedFloat32Array) -> float:
	var intervalStart: float = arr1[1]
	var intervalEnd: float = 0
	var intervalLength: int = 0
	var returnValue := 0
	
	for value in arr1:
		intervalLength += 1
		if (value == 0 || intervalLength < 2): continue
		
		intervalEnd = value
		
		for indexValue in intervalLength:
			returnValue = calculate(intervalLength - 1, intervalStart, intervalEnd, indexValue)
			
		intervalStart = intervalEnd
		intervalLength = 0
	return returnValue
	
func play_recorded():
	var data_size: int = abuf1.size() * 4  # 4 bytes per float (32-bit)
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
	for sample in abuf1:
		file.store_float(sample)
		#file.store_float(lerppaLerp(abuf1))
		
	file.close()
	abuf1.clear()
	
func _process(delta: float) -> void:
	#delta_time_in_samples = floor((bitrate * (0.00167*delta)) * IRCalcGlobalScene.time_scale)
	delta_time_in_samples = 60*IRCalcGlobalScene.time_scale
	while delta_time_in_samples > 0:
		if needle >= abuf1.size():
			abuf1.append(-currentpressure)
		else:
			abuf1[needle-1] = currentpressure
		#else:
		#	if abuf1[needle] != 0:
		#		abuf1.insert(needle+delta_time_in_samples, currentpressure) #padding the buffer with zeros
			needle += 1
		delta_time_in_samples -= 1


func _on_ear_area_exited(area: Area3D) -> void:
	pass
#	if !recording: return
#	if "AcPressure" in area.get_groups():
#		var pressure: float = area.get_meta("pressure")
#		currentpressure = pressure
#		abuf1.insert(needle, -1.0*pressure)
#		needle += 1
