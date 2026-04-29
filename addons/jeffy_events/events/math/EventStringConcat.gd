@tool
class_name EventStringConcatenate extends JEP_Event

@export_storage var line_1 : String
@export_storage var line_2 : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.DataSource.new(&"Output").without_input().with_type(3).with_output(0))\
			.with_element(ELEMENT.Line.new(&"line_1"))\
			.with_element(ELEMENT.Line.new(&"line_2"))

func _accept_data(port : int, data : Variant) -> void:
	if typeof(data) != TYPE_STRING:
		return
	
	if port == 0:
		line_1 = data
	if port == 1:
		line_2 = data

func _pull_data(port : int) -> Variant:
	if port == 0:
		return line_1 + line_2
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Concatenate String"

func _get_description() -> StringName:
	return &""
