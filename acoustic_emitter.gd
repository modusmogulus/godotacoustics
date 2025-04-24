@tool
extends Node3D
var pfield = preload("res://addons/ircalc/pressure_field.tscn")

@export
var dB_SPL: float
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_raytracing: bool = false
var is_optimizing: bool = false
var optimization_index: int = 0

var max_ray_dist: float = 10000.0

func _enter_tree() -> void:
	IRCalcGlobalScene.register_acoustic_emitter(self)

func _ready() -> void: #only for runtime, not run in editor
	_rng.randomize()

func set_currently_raytracing(value: bool):
	is_raytracing = value

func random_direction():
	# generate rnd unit vector (spherical coordinates)
	var theta = _rng.randf_range(0, 2 * PI)
	var phi = _rng.randf_range(-PI / 2, PI / 2)
	return Vector3(
		cos(theta) * cos(phi),
		sin(phi),
		sin(theta) * cos(phi)
	).normalized()
	
func _physics_process(delta: float) -> void:
	if is_raytracing:
		var space_state = get_world_3d().direct_space_state
		random_direction()
		var query = PhysicsRayQueryParameters3D.create(global_position, random_direction() * max_ray_dist)
		var result = space_state.intersect_ray(query)
		print(result)
		
	if is_optimizing:
			if optimization_index < IRCalcGlobalScene.emitter_count:
				for i in 16:
					var space_state = get_world_3d().direct_space_state
					var query = PhysicsRayQueryParameters3D.create(global_position, random_direction()*10000)
					var result = space_state.intersect_ray(query)
					if result.size() > 1: 
						var p = pfield.instantiate()
						#if Engine.is_editor_hint() == true:
						#	p.owner = EditorInterface.get_edited_scene_root().get_parent_node_3d()
						#else:
						#p.owner = get_tree().get_root()
						
						optimization_index += 1
						get_tree().get_root().add_child(p)
						p.velocity = Vector3(result.position - global_position).normalized()*1000
						p.look_at(p.velocity*1000)
						p.global_position = global_position + Vector3(result.position - global_position).normalized()
						IRCalcGlobalScene.emitters_created += 1
			else:
				is_optimizing = false
				optimization_index = 0
func create_pfields(count: int, global_pos: Vector3):
	if IRCalcGlobalScene.optimize_wave == true:
			is_optimizing = true
			return
	for i in count:
		
		#set_process(false) # Stop the _process() function
		#await get_tree().create_timer(0.01).timeout # wait 1 second
		#set_process(true) # start again the _process() function
		var p = pfield.instantiate()
		get_tree().get_root().add_child(p)
		#p.position.x = 1.1
		#if i%2 == 0: p.position.y = 1.1
		#global_rotation.z += 360*i / IRCalcGlobalScene.emitter_count
		#global_rotation.x += 360*i / IRCalcGlobalScene.emitter_count
		p.global_position = global_pos
		p.global_position.x += randf_range(-0.5*scale.x, 0.5*scale.x)
		#randomize()
		p.global_position.y += randf_range(-0.5*scale.y, 0.5*scale.y)
		#randomize()
		p.global_position.z += randf_range(-0.5*scale.z, 0.5*scale.z)
		#randomize()
		p.velocity = (p.global_position - global_position)*40000
		
		p.visualizer.set_surface_override_material(0, p.visualizer.get_surface_override_material(0).duplicate())
		#p.global_position = Vector3(cos(i), sin(i), cos(i)*PI)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_acoustic_emitter(self)

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Engine.is_editor_hint():	return #to disable this input handling in editor
	
	IRCalcGlobalScene.runtime_gizmo.select(self)
