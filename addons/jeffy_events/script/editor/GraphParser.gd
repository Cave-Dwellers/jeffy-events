@tool
class_name JEP_GraphParser extends Node

## Creates an event graph node from [class JEP_NodeInstruction], based
## on user provided [class JEP_InstructionHandler]. You can add new 
## instruction handlers using the plugin's frontend.

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

signal parsed(graph : JEP_EventGraph, nodes : Array[GraphNode])

func parse_graph(graph : JEP_EventGraph) -> void:
	var events : Dictionary[StringName, JEP_Event] = graph._events
	var nodes : Array[GraphNode] = []
	
	for uuid : StringName in events.keys():
		var event : JEP_Event = events[uuid]
		var instruction : JEP_NodeInstruction = event._get_instruction(graph)
		var graph_node := parse_instruction(instruction, graph)
		
		graph_node.name = uuid
		nodes.append(graph_node)
	
	parsed.emit(graph, nodes)

func parse_instruction(instruction : JEP_NodeInstruction, graph : JEP_EventGraph) -> JEP_EventGraphNode:
	var event : JEP_Event = instruction.event
	var uuid : StringName = graph.get_event_uuid(event)
	var graph_node : JEP_EventGraphNode = JEP_EventGraphNode.new(graph, uuid)
	
	graph_node.custom_minimum_size = Vector2(100, 100)
	graph_node.position_offset = event.position
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		graph_node = handler._handle_node_instruction(instruction, graph_node)
	
	for element_instruction : JEP_ElementInstruction in instruction.elements:
		parse_element_instruction(graph_node, event, element_instruction)
	
	return graph_node

func parse_element_instruction(graph_node : GraphNode, event : JEP_Event, instruction : JEP_ElementInstruction) -> void:
	var element : Control = Control.new()
	element.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	element.mouse_filter = Control.MOUSE_FILTER_IGNORE
	graph_node.add_child(element)
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		element = handler._handle_element_instruction(instruction, event, graph_node, element)
