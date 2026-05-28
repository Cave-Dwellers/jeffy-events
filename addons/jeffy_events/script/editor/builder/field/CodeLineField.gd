@tool
class_name JEP_CodeLineField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	field = configure_input(CodeEdit.new()) as CodeEdit
	
	# Disable the built in undo-redo features
	field.shortcut_keys_enabled = false
	field.context_menu_enabled = false
	
	field.size_flags_vertical = 0
	field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	field.scroll_fit_content_height = true
	
	if instruction._flat:
		field.theme_type_variation = &"CodeEditFlat"
	
	if instruction._placeholder_text:
		field.placeholder_text = instruction._placeholder_text
	
	field.text = event.get(property) as String
	return field

func _focus_exited_wrapper() -> void:
	field = field as CodeEdit
	_set_value(field.text)

func _on_value_changed() -> void:
	field.text = event.get(property)

func _connection_status_updated(connected : bool) -> void:
	field.set(&"editable", !connected)
	field.visible = !connected
