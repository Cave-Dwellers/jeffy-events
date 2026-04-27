@tool @abstract
class_name JEP_InstructionHandler extends GDScript

@abstract
func _handle_node_instruction(instruction : JEP_NodeInstruction, node : GraphNode) -> GraphNode

@abstract
func _handle_element_instruction(instruction : JEP_ElementInstruction, event : JEP_Event, node : GraphNode) -> Control
