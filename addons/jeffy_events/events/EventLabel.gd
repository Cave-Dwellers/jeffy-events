@tool
class_name EventLabel extends JEP_Event

@export_storage var label : String
@export_storage var some_bs : bool = true
@export_storage var number : int = 10

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return JEP_NodeInstruction.new(self)\
			.with_element(JEP_ElementInstruction.Port.new().with_output(0).with_label("Flow"))\
			.with_element(JEP_ElementInstruction.Port.new().with_output(1).with_label("Another one"))\
			.with_element(JEP_ElementInstruction.Line.new(&"label"))\
			.with_element(JEP_ElementInstruction.Bool.new(&"some_bs"))\
			.with_element(JEP_ElementInstruction.Number.new(&"number").with_range(0, 50))

func _get_name() -> StringName:
	return &"Label"

func _get_description() -> StringName:
	return &"""A starting point for an EventGraph."""
