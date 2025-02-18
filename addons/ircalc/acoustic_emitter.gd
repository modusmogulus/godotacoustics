@tool
extends Node3D
var pfield = preload("res://addons/ircalc/pressure_field.tscn")

@export
var dB_SPL: float

func _enter_tree() -> void:
	IRCalcGlobalScene.register_acoustic_emitter(self)

func _ready() -> void: #only for runtime, not run in editor
	pass

func create_pfields(count: int):
	for i in count:
		
		#set_process(false) # Stop the _process() function
		#await get_tree().create_timer(0.01).timeout # wait 1 second
		#set_process(true) # start again the _process() function
		var p = pfield.instantiate()
		if Engine.is_editor_hint() == true:
			p.owner = EditorInterface.get_edited_scene_root().get_parent_node_3d()
		else:
			p.owner = get_tree().get_root()
		add_sibling(p)
		#p.position.x = 1.1
		#if i%2 == 0: p.position.y = 1.1
		#global_rotation.z += 360*i / IRCalcGlobalScene.emitter_count
		#global_rotation.x += 360*i / IRCalcGlobalScene.emitter_count
		p.global_position = global_position
		p.global_position.x += randf_range(-0.5*scale.x, 0.5*scale.x)
		randomize()
		p.global_position.y += randf_range(-0.5*scale.y, 0.5*scale.y)
		randomize()
		p.global_position.z += randf_range(-0.5*scale.z, 0.5*scale.z)
		randomize()
		p.velocity = (p.global_position - global_position)*40000
		if IRCalcGlobalScene.optimize_wave == true:
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(global_position, (p.global_position-global_position)*10000)
			var result = space_state.intersect_ray(query)
			p.look_at((p.global_position - global_position)*40000)
			if result.size() < 1: 
				#p.global_position = global_position+(p.global_position-global_position)
				p.queue_free()
		p.visualizer.set_surface_override_material(0, p.visualizer.get_surface_override_material(0).duplicate())
		#p.global_position = Vector3(cos(i), sin(i), cos(i)*PI)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_acoustic_emitter(self)

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Engine.is_editor_hint():	return #to disable this input handling in editor
	
	IRCalcGlobalScene.runtime_gizmo.select(self)
