@tool
class_name JEP_GraphParser extends Node

## Creates an event graph node from [class JEP_NodeInstruction], based
## on user provided [class JEP_InstructionHandler]. You can add new 
## instruction handlers using the plugin's frontend.

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

signal parsed(nodes : Array[GraphNode])

func parse_graph(graph : JEP_EventGraph) -> void:
	var events : Array[JEP_Event] = graph._events
	var nodes : Array[GraphNode] = []
	
	for event : JEP_Event in events:
		var instruction : JEP_NodeInstruction = event._get_instruction(graph)
		var graph_node := parse_instruction(instruction)
		nodes.append(graph_node)
	
	parsed.emit(nodes)

func parse_instruction(instruction : JEP_NodeInstruction) -> GraphNode:
	var graph_node : GraphNode = GraphNode.new()
	var event : JEP_Event = instruction.event
	
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
