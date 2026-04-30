@tool
class_name EventNumberOp extends JEP_Event

const OPERATIONS : Array[String] = ["Add", "Subtract", "Multiply", "Divide", "Modulo"]

@export_storage var operation : String
@export_storage var number_1 : float = 0.0
@export_storage var number_2 : float = 0.0
@export_storage var rounded : bool = true

func _event(ctx : Object = null) -> int:
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.DataSource.new(&"Output").without_input().with_type(2).with_output(0))\
			.with_element(ELEMENT.EnumLine.new(&"operation").with_strings(OPERATIONS).without_input())\
			.with_element(ELEMENT.Number.new(&"number_1").with_step(0.1))\
			.with_element(ELEMENT.Number.new(&"number_2").with_step(0.1))

func _accept_data(port : int, data : Variant) -> void:
	if typeof(data) not in [TYPE_INT, TYPE_FLOAT]:
		return
	
	if port == 0:
		number_1 = data
	if port == 1:
		number_2 = data

func _pull_data(port : int) -> Variant:
	if port != 0:
		return null
	match operation:
		"Add": return number_1 + number_2
		"Subtract": return number_1 - number_2
		"Multiply": return number_1 * number_2
		"Divide": return number_1 / number_2
		"Modulo": return int(number_1) % int(number_2) # Will always be rounded
	return null

func is_data() -> bool:
	return true

func _get_name() -> StringName:
	return &"Number Operation"

func _get_description() -> StringName:
	return &"Performs a mathematical operation on two provided numbers"
