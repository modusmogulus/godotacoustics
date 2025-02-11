@tool
extends Node3D


var abuf1: PackedFloat32Array = [] #virtual audio buffer
var time: float = 0.0
var buf = $ear/buf
var pr: float = 0.0 #pressure
 
func start_rec() -> void:
	abuf1.fill(0.0)
	time = 0.0
func _enter_tree() -> void:
	IRCalcGlobalScene.register_listener(self)

func  _exit_tree() -> void:
	IRCalcGlobalScene.unregister_listener(self)

func _on_ear_area_entered(area: Area3D) -> void:
	abuf1.append(area.pressure)

func _physics_process(delta: float) -> void:
	time += delta
