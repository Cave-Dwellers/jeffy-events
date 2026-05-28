@tool
class_name JEP_LineField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	field = configure_input(LineEdit.new()) as LineEdit
	
	# Disable the built in undo-redo features
	field.shortcut_keys_enabled = false
	field.context_menu_enabled = false
	
	if instruction._max_character_count != -1:
		field.max_length = instruction._max_character_count
	
	field.text = event.get(property) as String
	return field

func edit_toggled_wrapper(on : bool) -> void:
	if on:
		return
	
	_set_value(field.text)

func _on_value_changed() -> void:
	var value : String = event.get(property)
	field = field as LineEdit
	field.text = value

func _connection_status_updated(connected : bool) -> void:
	field.set(&"editable", !connected)
	field.visible = !connected
