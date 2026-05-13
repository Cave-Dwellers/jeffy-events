@tool
class_name EventPrint extends JEP_Event

@export_storage var to_print : String
@export_storage var keys : Array[StringName]

var format : Dictionary = {}

func _event(ctx : JEP_GraphContext) -> int:
	to_print = to_print.format(format) 
	print("[JeffyEvents] %s" % to_print)
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	var regex : RegEx = RegEx.create_from_string("\\{([^}]+)\\}")
	var matches : Array[RegExMatch] = regex.search_all(to_print)
	
	keys.clear()
	for entry : RegExMatch in matches: 
		var string : String = entry.strings[0]
		string = string.lstrip('{').rstrip('}')
		keys.append(string)
	
	var builder : JEP_NodeInstruction =\
				NODE.new(graph, self).dynamic()\
				.with_element(
						ELEMENT.Port.new()\
							.with_input()\
							.with_output()
							.with_label("Flow")
				)\
				.with_element(
						ELEMENT.CodeLine.new(&"to_print")\
							.with_placeholder(&"Print...")\
							.without_input()
				)
	
	for placeholder : String in keys:
		builder.with_element(ELEMENT.DataSource.new(placeholder).with_type(3))
	
	return builder

func _accept_data(port : int, data : Variant) -> void:
	var key : StringName = keys[port - 1]
	format.set(key, data)

func _get_name() -> StringName:
	return &"Print"

func _get_description() -> StringName:
	return &"Outputs text to console"
