@tool
class_name JEP_GraphParser extends Node

## Creates an event graph node from [JEP_NodeInstruction], based
## on user provided [JEP_InstructionHandler]. You can add new 
## instruction handlers using the plugin's frontend.

signal parsed(graph : JEP_EventGraph, nodes : Array[GraphNode])

func parse_graph(graph : JEP_EventGraph) -> void:
	var events : Dictionary[StringName, JEP_Event] = graph._events
	var nodes : Array[GraphNode] = []
	
	for uuid : StringName in events.keys():
		var event : JEP_Event = events[uuid]
		var graph_node := JEP_EventGraphNode.new(event, graph)
		
		graph_node.name = uuid
		nodes.append(graph_node)
	
	parsed.emit(graph, nodes)
