@tool
class_name EventComment extends JEP_Event

@export_storage var text : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(self).with_element(
		ELEMENT.CodeLine.new(&"text")\
						.with_placeholder(&"Comment...")\
						.as_flat()\
						.without_input())

func _get_name() -> StringName:
	return &"Comment"

func _get_description() -> StringName:
	return &"A comment block for documentation"
