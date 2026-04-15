@tool
class_name EventComment extends JEP_Event

@export_storage var text : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return JEP_NodeInstruction.new(self)\
			.with_element(JEP_ElementInstruction.Line.new(&"text"))

func _get_name() -> StringName:
	return &"Comment"

func _get_description() -> StringName:
	return &"""A comment block for documentation"""
