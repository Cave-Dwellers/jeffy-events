@tool @abstract
class_name JEP_InstructionHandler extends GDScript

@abstract
func _handle_node_instruction(instruction : JEP_NodeInstruction, node : JEP_EventGraphNode) -> GraphNode

@abstract
func _handle_element_instruction(instruction : JEP_ElementInstruction, event : JEP_Event, node : JEP_EventGraphNode) -> Control
