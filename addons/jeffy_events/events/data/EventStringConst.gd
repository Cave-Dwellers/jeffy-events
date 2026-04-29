@tool
class_name EventStringConst extends JEP_Event

@export_storage var value : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self).with_element(ELEMENT.Line.new(&"value").without_input().with_output(0))

func _pull_data(port : int) -> Variant:
	if port == 0:
		return value
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"String Constant"

func _get_description() -> StringName:
	return &"Sends a string data constant"
