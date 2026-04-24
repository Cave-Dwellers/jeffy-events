@tool
class_name JEP_EventGraphNode extends GraphNode

var graph : JEP_EventGraph
var uuid : StringName

func _init(p_graph : JEP_EventGraph, p_uuid : StringName) -> void:
	graph = p_graph
	uuid = p_uuid

func get_event() -> JEP_Event:
	return graph._events.get(uuid)
