@tool
class_name EventFloatConst extends JEP_Event

@export_storage var value : float

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self).with_element(ELEMENT.Number.new(&"value").with_step(0.1).without_input().with_output(0))

func _pull_data(port : int) -> Variant:
	if port == 0:
		return value
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Float Constant"

func _get_description() -> StringName:
	return &"Sends a float data constant"
