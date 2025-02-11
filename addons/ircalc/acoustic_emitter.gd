@tool
extends Node3D
var pfield = preload("res://addons/ircalc/pressure_field.tscn")

func _enter_tree() -> void:
	IRCalcGlobalScene.register_acoustic_emitter(self)

func create_pfields(count: int):
	for i in count:
		var p = pfield.instantiate()
		if Engine.is_editor_hint() == true:
			p.owner = EditorInterface.get_edited_scene_root().get_parent_node_3d()
		else:
			p.owner = get_tree().get_root()
		add_child(p)
		#p.position.x = 1.1
		#if i%2 == 0: p.position.y = 1.1
		#global_rotation.z += 360*i / IRCalcGlobalScene.emitter_count
		#global_rotation.x += 360*i / IRCalcGlobalScene.emitter_count
		p.global_position.x += randf_range(-0.5*scale.x, 0.5*scale.x)
		randomize()
		p.global_position.y += randf_range(-0.5*scale.y, 0.5*scale.y)
		randomize()
		p.global_position.z += randf_range(-0.5*scale.z, 0.5*scale.z)
		randomize()
		p.velocity = (p.global_position - global_position)*40000
		p.look_at((p.global_position - global_position)*40000)
		#p.global_position = Vector3(cos(i), sin(i), cos(i)*PI)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_acoustic_emitter(self)
