@tool
extends CharacterBody3D
var vel_fixed: Vector3
var simu: bool = false
var soundspeed: float = 343
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
	soften_diffuse = IRCalcGlobalScene.soften_diffuse
	soundspeed = IRCalcGlobalScene.soundspeed

func _enter_tree() -> void:
	IRCalcGlobalScene.register_pressure_field(self)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_pressure_field(self)
	
func _physics_process(delta: float) -> void:
	if simu == false: return
	pressure = 0.98
	#print(pressure)
	$wavetable.volume_db *= pressure
	if $wavetable && $wavetable.playing == false: $wavetable.play()
	$Soundfield.scale += Vector3(soften_diffuse*delta, soften_diffuse*delta, soften_diffuse*delta)
	for area in $Forcefield.get_overlapping_areas():
		if area != $Forcefield:
			if absf(velocity.dot(area.get_parent().velocity)) < 0.1 or velocity.length() < 1.0:
				velocity += (global_position - area.global_position) * 1.55
			#velocity += velocity.reflect((velocity - area.get_parent().velocity).normalized())*0.1
			
			#area.get_parent().velocity -= velocity
	
	
	
		#velocity = -velocity
	#velocity = clamp(velocity, Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))
	velocity = velocity * 4096
	velocity = velocity.normalized() * soundspeed
	
	var bodies = move_and_collide(velocity*delta)
	if bodies: 
		velocity = 0.8*velocity + bodies.get_normal()*soundspeed
		pressure *= 0.5
