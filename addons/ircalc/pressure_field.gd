@tool
extends CharacterBody3D
var vel_fixed: Vector3

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

func fix_velocity(vel: Vector3) -> Vector3:
	return clamp(vel.normalized() * 4096, Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))*IRCalcGlobalScene.soundspeed
	
func _enter_tree() -> void:
	IRCalcGlobalScene.register_pressure_field(self)
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_pressure_field(self)
	
func _physics_process(delta: float) -> void:
	for body in $Forcefield.get_overlapping_areas():
		velocity += (global_position - body.global_position)
	velocity = fix_velocity(velocity)*delta
	
	move_and_slide() 
