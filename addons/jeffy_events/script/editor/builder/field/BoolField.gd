@tool
class_name JEP_BoolField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	field = configure_input(CheckBox.new()) as CheckBox
	
	field.toggle_mode = true
	field.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	field.size_flags_horizontal = Control.SIZE_SHRINK_END
	field.button_pressed = event.get(property) as bool
	
	return field

func _on_value_changed() -> void:
	var value : bool = event.get(property)
	field = field as CheckBox
	
	field.set_pressed_no_signal(value)

func _connection_status_updated(connected : bool) -> void:
	field.set(&"disabled", connected)
	field.visible = !connected
