@tool
class_name EventJumpToLabel extends JEP_Event

@export_storage var label : String

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self).dynamic()\
			.with_element(ELEMENT.Port.new().with_input().with_label("Terminate Flow"))\
			.with_element(ELEMENT.EnumLine.new(&"label").with_strings(graph._labels).without_input())

func _get_name() -> StringName:
	return &"Jump To Label"

func _get_description() -> StringName:
	return &"""Restarts graph execution at the provided label."""
