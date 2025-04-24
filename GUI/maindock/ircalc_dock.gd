@tool
extends EditorPlugin
#        ---^  Note: this is not inherited by any node! This just spawns the dock
#              The script for the node which handles GUI is called ircalc_dock_node.gd
#                                                                  '''''''''''''''''''

var dock

func _enter_tree() -> void:
	dock = preload("res://addons/ircalc/GUI/maindock/ircalc_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, dock)
	
func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
