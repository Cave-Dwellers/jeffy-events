@tool
class_name EventStringify extends JEP_Event

@export_storage var input : Variant

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.DataSource.new(&"Output").without_input().with_output().with_type(3))\
			.with_element(ELEMENT.DataSource.new(&"Input").with_type(1))

func _accept_data(port : int, data : Variant) -> void:
	if port == 0:
		input = data

func _pull_data(port : int, ctx : JEP_GraphContext) -> Variant:
	if port == 0:
		return type_convert(input, TYPE_STRING)
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Stringify"

func _get_description() -> StringName:
	return &"Turns input into a string data value"
