@tool
class_name EventLabel extends JEP_Event

@export_storage var label : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self).dynamic()\
			.with_element(ELEMENT.Port.new().with_output(0).with_label("Flow"))\
			.with_element(ELEMENT.EnumLine.new(&"label").with_strings(graph._labels).without_input())

func _get_name() -> StringName:
	return &"Label"

func _get_description() -> StringName:
	return &"""A starting point for an EventGraph."""
