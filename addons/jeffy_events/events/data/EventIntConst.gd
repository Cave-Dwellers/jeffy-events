@tool
class_name EventIntConst extends JEP_Event

@export_storage var value : int

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self).with_element(ELEMENT.Number.new(&"value").with_rounding().without_input().with_output())

func _pull_data(port : int, ctx : JEP_GraphContext) -> Variant:
	if port == 0:
		return value
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Integer Constant"

func _get_description() -> StringName:
	return &"Sends an integer data constant"
