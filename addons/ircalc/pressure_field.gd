@tool
extends StaticBody3D
var vel_fixed: Vector3
var simu: bool = false
var soundspeed: float = 343
var timescale: float = 1.0
var final_sndspd: float
var velocity: Vector3
var pressure: float = 1.0
var soften_diffuse: float
var dB_SPL: float = 1.0
@export
var visualizer: MeshInstance3D
@export var pressurearea: Area3D
var reflection_history: int = 0
var material
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
	timescale = IRCalcGlobalScene.time_scale
	soften_diffuse = IRCalcGlobalScene.soften_diffuse*IRCalcGlobalScene.time_scale
	soundspeed = IRCalcGlobalScene.soundspeed
	material = visualizer.get_surface_override_material(0)
	$GPUParticles3D.speed_scale = timescale
func _enter_tree() -> void:
	IRCalcGlobalScene.register_pressure_field(self)
	
	
	
func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_pressure_field(self)
	
func _physics_process(delta: float) -> void:
	
	
	
	if simu == false: return

	pressure = pressure*(1-(0.01*timescale))
	#dB_SPL = log(pressure) / log(10)*10 #Godot logarithm is NOT base 10 by default. This fixes it
	#But the real question is... WHAT THE FUCK IS A LOGARITHM?????
	#ALL MATH CLASSES I TOOK USES FUCKING DIFFERENT BASES OR NUMBERS OF ARGUMENTS???
	
	pressurearea.set_meta("pressure", pressure)
	pressurearea.set_meta("dB_SPL", dB_SPL)
	var col2 = Color(Color.from_hsv(1-0.7*pressure, 1.0, 1.0, 1.0))
	
	#$Soundfield/FogVolume.material.albedo = col2
	var col = Color.WHITE
	col.a = smoothstep(0.0, 0.01, pressure*0.5)
	material.set_shader_parameter("color", col)
	visualizer.set_surface_override_material(0, material)
		
	#$GPUParticles3D.emitting = true
	#print(pressure)
	look_at(velocity*1000)
	#$wavetable.volume_db -= 0.005
	#if $wavetable && $wavetable.playing == false: $wavetable.play()
	if soften_diffuse>0.0: $Soundfield.scale += (Vector3(soften_diffuse, soften_diffuse, soften_diffuse))
	for area in $Forcefield.get_overlapping_areas():
		if area != $Forcefield && area:
			if absf(velocity.dot(area.get_parent().velocity)) < 0.5 or velocity.length() < 1.0:
				velocity += (global_position - area.global_position) * area.get_parent().velocity
				#velocity += (global_position - area.global_position) * (1-velocity.dot(area.get_parent().velocity))*500
			#velocity += velocity.reflect((velocity - area.get_parent().velocity).normalized())*0.1
			
			#area.get_parent().velocity -= velocity
	
	if get_parent_node_3d().scale.y < 0.5: velocity.y = 0.0
	
		#velocity = -velocity
	#velocity = clamp(velocity, Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))
	velocity = velocity * 4096
	#velocity.y = 0
	velocity = velocity.normalized() * soundspeed * timescale
	
	var bodies = move_and_collide(velocity*1/60)
	
	if bodies:
		if reflection_history > 512: queue_free()
		pressure *= 1-(pressure*0.01*timescale)
		
		if bodies.has_meta("AcousticMaterial"):
			var acmat: AcousticMaterial = bodies.get_meta("AcousticMaterial")
			pressure *= 1-(pressure*acmat.absorption)
			
		pressure = -pressure*randf_range(0.9, 1.0)
		reflection_history += 1
		#$GPUParticles3D.emitting = true
		#$FogVolume.visible = true
		col = Color.WHITE
		material.set_shader_parameter("metalness", 0.0)
		#$Soundfield.visible = true
		
		velocity = (0.8*velocity + bodies.get_normal()*soundspeed)* timescale
		#$Soundfield.scale = $Soundfield.scale * 0.9
		#dup.velocity.x += randf_range(-0.01, 0.01)
		#dup.velocity.y += randf_range(-0.01, 0.01)
		#dup.velocity.z += randf_range(-0.01, 0.01)
		#$wavetable.volume_db -= 0.015
