@tool
class_name EventNodePathConst extends JEP_Event

@export_storage var value : NodePath

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.NodePathField.new(&"value").without_input().with_output())
			
func _pull_data(port : int, ctx : JEP_GraphContext) -> Variant:
	if port == 0:
		return value
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"NodePath Constant"

func _get_description() -> StringName:
	return &"Sends a NodePath constant"
