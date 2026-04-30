@tool
class_name EventPrint extends JEP_Event

@export_storage var to_print : String
@export_storage var placeholders : Dictionary[StringName, Variant]

func _event(ctx : Object = null) -> int:
	to_print = to_print.format(placeholders) 
	print("[JeffyEvents] %s" % to_print)
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	var regex : RegEx = RegEx.create_from_string("\\{([^}]+)\\}")
	var matches : Array[RegExMatch] = regex.search_all(to_print)
	
	placeholders.clear()
	for entry : RegExMatch in matches: 
		var string : String = entry.strings[0]
		string = string.lstrip('{').rstrip('}')
		placeholders[string] = null
	
	var builder : JEP_NodeInstruction =\
				NODE.new(graph, self).dynamic()\
				.with_element(
						ELEMENT.Port.new()\
							.with_input()\
							.with_output(0)
							.with_label("Flow")
				)\
				.with_element(
						ELEMENT.CodeLine.new(&"to_print")\
							.with_placeholder(&"Print...")\
							.without_input()
				)
	
	for placeholder : String in placeholders.keys():
		builder.with_element(ELEMENT.DataSource.new(placeholder).with_type(3))
	
	return builder

func _accept_data(port : int, data : Variant) -> void:
	var key : StringName = placeholders.keys()[port - 1]
	placeholders.set(key, data)

func _get_name() -> StringName:
	return &"Print"

func _get_description() -> StringName:
	return &"Outputs text to console"
