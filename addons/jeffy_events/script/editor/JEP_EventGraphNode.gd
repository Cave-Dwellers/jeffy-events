@tool
class_name JEP_EventGraphNode extends GraphNode

var graph : JEP_EventGraph
var event : JEP_Event

func _init(p_graph : JEP_EventGraph, p_event : JEP_Event) -> void:
	graph = p_graph
	event = p_event
