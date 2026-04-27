@tool
class_name JeffyEventsPlugin extends EditorPlugin

const SOURCES_PATH : StringName = &"res://addons/jeffy_events/sources.tres"
const SOURCES : JEP_EventDatabase = preload("res://addons/jeffy_events/sources.tres")

const SCN_FRONTEND: PackedScene = preload("res://addons/jeffy_events/scene/frontend.tscn")
const ICO_FRONTEND: Texture2D = preload("res://addons/jeffy_events/asset/icon/EventGraphEditor.svg")

## Reference to the current frontend
var frontend : JEP_Frontend
## Reference to the plugin dock
var jep_dock : EditorDock

func _enter_tree() -> void:
	create_dock()
	
	# Connect signal
	if is_instance_valid(SOURCES):
		SOURCES.changed.connect(_on_source_change.bind())

func _exit_tree() -> void:
	if is_instance_valid(jep_dock):
		_disable_plugin()

func _disable_plugin() -> void:
	# Remove our dock
	if is_instance_valid(jep_dock):
		remove_dock(jep_dock)
		jep_dock.queue_free()
		jep_dock = null

## Creates the frontend dock
func create_dock() -> void:
	# Create dock for our frontend
	jep_dock = EditorDock.new()
	jep_dock.name = "Event Graph Editor"
	jep_dock.dock_icon = ICO_FRONTEND
	jep_dock.closable = false
	jep_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	
	# Add the frontend to the dock
	frontend = SCN_FRONTEND.instantiate() as JEP_Frontend
	jep_dock.add_child(frontend)
	add_dock(jep_dock)
	
	# Mark as ready
	frontend._dock_ready()

func _get_plugin_name() -> String:
	return "JeffyEvents"

func _get_plugin_icon() -> Texture2D:
	return ICO_FRONTEND

func _handles(object: Object) -> bool:
	return object is JEP_EventGraph

func _save_external_data() -> void:
	frontend.save_requested.emit()

## Called when EventSource changes
func _on_source_change() -> void:
	ResourceSaver.save(SOURCES, SOURCES_PATH)
