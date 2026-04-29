@tool
class_name JEP_EventGraphNode extends GraphNode

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

var _event : JEP_Event
var _uuid : StringName

func _init(event : JEP_Event, graph : JEP_EventGraph) -> void:
	_event = event
	_uuid = graph.get_event_uuid(event)
	
	slot_sizes_changed.connect(reset_size)
	position_offset = event.position
	
	parse_instruction(event, graph)

func parse_instruction(event : JEP_Event, graph : JEP_EventGraph) -> void:
	# Remove existing
	for child in get_children():
		if child is not Control:
			continue
		child.queue_free()
		await child.tree_exited
	
	var instruction := event._get_instruction(graph)
	if !instruction.is_static:
		graph.changed.connect(parse_instruction.bind(event, graph), CONNECT_ONE_SHOT)
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_node_instruction(instruction, self)
	
	for element_instruction : JEP_ElementInstruction in instruction.elements:
		parse_element_instruction(self, event, element_instruction)
	
	reset_size.call_deferred()

func parse_element_instruction(graph_node : GraphNode, event : JEP_Event, instruction : JEP_ElementInstruction) -> void:
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_element_instruction(instruction, event, graph_node)

func get_event() -> JEP_Event:
	return _event
