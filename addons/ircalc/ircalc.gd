@tool
extends EditorPlugin

var dock
const IRCALC_GLOBALS = "IRCalcGlobalScene"

func _enable_plugin():
	# The autoload can be a scene or script file.
	add_autoload_singleton(IRCALC_GLOBALS, "res://addons/ircalc/ircalc_global.tscn")

func _enter_tree() -> void:
	add_custom_type("IRCalcAcousticRay", "RayCast3D", preload("res://addons/ircalc/acoustic_ray.gd"), preload("res://addons/ircalc/icon.svg"))
	add_custom_type("IRCalcAcousticMaterial", "Resource", preload("res://addons/ircalc/resAcousticMaterial.gd"), preload("res://addons/ircalc/icon.svg"))
	dock = preload("res://addons/ircalc/GUI/maindock/ircalc_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	remove_custom_type("IRCalcAcousticRay")
	dock.free()
	
func _disable_plugin():
	remove_autoload_singleton(IRCALC_GLOBALS)
