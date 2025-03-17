extends Resource
class_name AcousticRayHit
#Raytracing stuff
var distance_travelled : float = 0.0
var distance_to_listener : float = 0.0
var hit_absorption : float = 0.0
var waveform : PackedFloat32Array = [0.0, 0.1, 0.25, 0.1, 0.25, 0.1, 0.0]
var pitch : float = 1.0
