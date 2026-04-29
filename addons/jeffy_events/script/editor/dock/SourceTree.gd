@tool
class_name JEP_SourceTree extends Tree

## Handles drag and drop of events

const THEME : Theme = preload("res://addons/jeffy_events/asset/theme.tres")

@export var graph_parser : JEP_GraphParser
@export var graph_frontend : JEP_EventGraphFrontend
var current_graph : JEP_EventGraph = null

func _on_graph_selected(graph : JEP_EventGraph) -> void:
	current_graph = graph

func _get_drag_data(at_position: Vector2) -> Variant:
	if !current_graph:
		return null
	
	var element : TreeItem = get_selected()
	if !element:
		return null
	
	var script : GDScript = element.get_metadata(0)
	if !script:
		return null
	
	var event : JEP_Event = script.new()
	var node : JEP_EventGraphNode = JEP_EventGraphNode.new(event, current_graph)
	
	node.modulate = Color(1, 1, 1, 0.5)
	node.scale = Vector2.ONE * graph_frontend.zoom
	node.theme = THEME
	
	set_drag_preview(node)
	return event
