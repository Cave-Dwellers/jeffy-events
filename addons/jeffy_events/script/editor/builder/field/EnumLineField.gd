@tool
class_name JEP_EnumLineField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	var value : Variant = event.get(property)
	field = configure_input(OptionButton.new()) as OptionButton
	
	# Enum keys tend to be long, so element should have more
	# priority in sizing
	field.size_flags_stretch_ratio = 1.5
	field.autowrap_mode = TextServer.AUTOWRAP_OFF
	field.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	if instruction._strings.is_empty():
		JEP_Print.error("Strings not provided to EnumLine instruction - %s" % property)
		return
	
	var strings : PackedStringArray = instruction._strings
	for i : int in range(strings.size()):
		var entry : String = strings.get(i)
		field.add_item(entry, i)
		
		if value == entry:
			field.select(field.get_item_index(i))
	
	# If no default value, select first option in enum
	if field.get_selected_id() == -1:
		field.select(0)
	return field

func _selected_wrapper(idx : int) -> void:
	field = field as OptionButton
	_set_value(field.get_item_text(idx))

func _on_value_changed() -> void:
	var value : String = event.get(property)
	
	for i : int in range(field.item_count):
		if field.get_item_text(i) == value:
			field.selected = i
			break

func _connection_status_updated(connected : bool) -> void:
	field.set(&"disabled", connected)
	field.visible = !connected
