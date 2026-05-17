@tool
class_name EventResourceConst extends JEP_Event

@export_storage var value : Resource
@export_storage var unique : bool

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.ResourceField.new(&"value").without_input().with_output())\
			.with_element(ELEMENT.Bool.new(&"unique").without_input().with_label(&"As Unique"))

func _pull_data(port : int, ctx : JEP_GraphContext) -> Variant:
	if port == 0:
		return value if !duplicate else value.duplicate(true)
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Resource Constant"

func _get_description() -> StringName:
	return &"Sends a resource constant, optionally as a unique duplicate of the provided resource"
