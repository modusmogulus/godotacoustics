@tool
extends MeshInstance3D
var time = 0
@export var reduce_update_rate: int = 10 
func _enter_tree() -> void:
	IRCalcGlobalScene.register_waveguide(self)

func _exit_tree() -> void:
	IRCalcGlobalScene.unregister_waveguide(self)

func begin():
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	

func shut():
	mesh.surface_end()
	
func add_verts(pos: PackedVector3Array, normal: PackedVector3Array):
	global_position = Vector3.ZERO
	begin()
	#pos.sort()
	#normal.sort()
	for i in pos.size():
		#if i > 1: mesh.surface_set_normal(pos[i].normalized().cross((pos[i-1]).normalized()))
		mesh.surface_set_normal(normal[i].normalized())
		mesh.surface_set_uv(Vector2(pos[i-1].x, pos[i].y))
		mesh.surface_add_vertex(pos[i])
	shut()

func _process(delta: float) -> void:
	time += 1
	if time > reduce_update_rate:
		IRCalcGlobalScene.update_waveguides()
		time = 0
		#this is jank but at least it works...
