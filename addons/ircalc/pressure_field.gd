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

func _enter_tree() -> void:
	IRCalcGlobalScene.register_pressure_field(self)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_pressure_field(self)
	
func _physics_process(delta: float) -> void:
	if simu == false: return
	
	$Soundfield.scale += Vector3(soften_diffuse*delta, soften_diffuse*delta, soften_diffuse*delta)
	for area in $Forcefield.get_overlapping_areas():
		if area != $Forcefield:
			velocity += (global_position - area.global_position)
	if get_last_slide_collision():
		velocity = -velocity.reflect(get_last_slide_collision().get_normal())
	#velocity = clamp(velocity, Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))
	velocity = velocity * 4096
	velocity = velocity.normalized() * soundspeed
	
	move_and_slide()
