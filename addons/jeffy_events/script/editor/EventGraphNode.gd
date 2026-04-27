@tool
class_name JEP_EventGraphNode extends GraphNode

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

var event : JEP_Event
var uuid : StringName

func _init(instruction : JEP_NodeInstruction, graph : JEP_EventGraph) -> void:
	event = instruction.event
	uuid = graph.get_event_uuid(event)
	
	parse_instruction(instruction, graph)

func parse_instruction(instruction : JEP_NodeInstruction, graph : JEP_EventGraph) -> void:
	# Remove existing
	for child in get_children():
		if child is not Control:
			continue
		child.queue_free()
	
	var event : JEP_Event = instruction.event	
	position_offset = event.position
	slot_sizes_changed.connect(reset_size)
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_node_instruction(instruction, self)
	
	for element_instruction : JEP_ElementInstruction in instruction.elements:
		parse_element_instruction(self, event, element_instruction)

func parse_element_instruction(graph_node : GraphNode, event : JEP_Event, instruction : JEP_ElementInstruction) -> void:
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_element_instruction(instruction, event, graph_node)

func get_event() -> JEP_Event:
	return event
