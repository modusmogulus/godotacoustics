@tool
extends Node3D
var pfield = preload("res://addons/ircalc/pressure_field.tscn")

func _enter_tree() -> void:
	IRCalcGlobalScene.register_acoustic_emitter(self)

func create_pfields(count: int):
	var p = pfield.instantiate()
	p.owner = self
	add_child(p)
	print("pfields were created")

func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_acoustic_emitter(self)
