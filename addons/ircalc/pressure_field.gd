@tool
extends StaticBody3D
var vel_fixed: Vector3
var simu: bool = false
var soundspeed: float = 343
var timescale: float = 1.0
var final_sndspd: float
var velocity: Vector3
var pressure = 1.0
var soften_diffuse: float

# =================== The laws for this scene ========
#    
#    (1)
#    All pressure fields have fixed magnitude of velocity, 
#    which should never change (speed of sound in air)
#
#    (2)
#    All pressure fields move apart from each other (this causes diffusion). 
#    If this is not possible, they pass trough each other and the phase 
#    and pressure is changed by how much the velocity vectors oppose 
#    each other.
#
#    (3)
#    Among time, pressure should decrease linearly while the 
#    size of the field/wavelength scales up 
#    (which filters off high frequencies caused by air absorption)
#
#======================= * ==========================


func set_simulating(value: bool):
	simu = value
	soften_diffuse = IRCalcGlobalScene.soften_diffuse/(343/soundspeed)
	soundspeed = IRCalcGlobalScene.soundspeed
	
	
func _enter_tree() -> void:
	IRCalcGlobalScene.register_pressure_field(self)
	
	
	
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_pressure_field(self)
	
func _physics_process(delta: float) -> void:
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(global_position+global_basis.z*1000, -global_basis.z*10000)
	var result = space_state.intersect_ray(query)
	#if result.size() < 1: queue_free()
	
	if simu == false: return
	
	#print(pressure)
	look_at(velocity*1000)
	$wavetable.volume_db -= 0.005
	#if $wavetable && $wavetable.playing == false: $wavetable.play()
	if soften_diffuse>0.0: $Soundfield.scale += (Vector3(soften_diffuse*delta, soften_diffuse*delta, soften_diffuse*delta))
	for area in $Forcefield.get_overlapping_areas():
		if area != $Forcefield && area:
			if absf(velocity.dot(area.get_parent().velocity)) < 0.1 or velocity.length() < 1.0:
				velocity += (global_position - area.global_position) * 1.55
			#velocity += velocity.reflect((velocity - area.get_parent().velocity).normalized())*0.1
			
			#area.get_parent().velocity -= velocity
	
	if get_parent_node_3d().scale.y < 0.5: velocity.y = 0.0
	
		#velocity = -velocity
	#velocity = clamp(velocity, Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))
	velocity = velocity * 4096
	#velocity.y = 0
	velocity = velocity.normalized() * soundspeed
	
	var bodies = move_and_collide(velocity*1/60)
	
	if bodies:
		velocity = 0.8*velocity + bodies.get_normal()*soundspeed
		
		#dup.velocity.x += randf_range(-0.01, 0.01)
		#dup.velocity.y += randf_range(-0.01, 0.01)
		#dup.velocity.z += randf_range(-0.01, 0.01)
		$wavetable.play()
		$wavetable.volume_db -= 0.015
