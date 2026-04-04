@tool
extends EditorPlugin
class_name JeffyEventsPlugin

const SCN_FRONTEND: PackedScene = preload("res://addons/jeffy_events/scene/frontend.tscn")
const ICO_FRONTEND: Texture2D = preload("res://addons/jeffy_events/asset/icon/EventGraphEditor.svg")

## Reference to the current frontend
var frontend : Control
## Reference to the plugin dock
var jep_dock : EditorDock

func _enable_plugin() -> void:
	# Create dock for our frontend
	jep_dock = EditorDock.new()
	jep_dock.name = "Event Graph Editor"
	jep_dock.dock_icon = ICO_FRONTEND
	jep_dock.closable = false
	jep_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	
	# Add the frontend to the dock
	frontend = SCN_FRONTEND.instantiate()
	jep_dock.add_child(frontend)
	add_dock(jep_dock)

func _disable_plugin() -> void:
	# Remove our dock
	if is_instance_valid(jep_dock):
		remove_dock(jep_dock)
		jep_dock.queue_free()
		jep_dock = null

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
