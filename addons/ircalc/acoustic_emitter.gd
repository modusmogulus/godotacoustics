@tool
extends Node3D
var pfield = preload("res://addons/ircalc/pressure_field.tscn")

func _enter_tree() -> void:
	IRCalcGlobalScene.register_acoustic_emitter(self)

func create_pfields(count: int):
	for i in count:
		var p = pfield.instantiate()
		p.owner = EditorInterface.get_edited_scene_root().get_parent_node_3d()
		add_child(p)
		p.global_position.x += randf_range(-0.5, 0.5)
		randomize()
		p.global_position.y += randf_range(-0.5, 0.5)
		randomize()
		p.global_position.z += randf_range(-0.5, 0.5)
		randomize()
		print("pfields were created")

func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_acoustic_emitter(self)
