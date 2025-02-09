@tool
extends Node3D
var pfield = preload("res://addons/ircalc/acoustic_emitter.tscn").instantiate()

func _enter_tree() -> void:
	pass

func create_pfields(count: int):
	pfield.owner = EditorInterface.get_edited_scene_root().get_parent_node_3d()
	get_tree().get_edited_scene_root().add_child(pfield)
