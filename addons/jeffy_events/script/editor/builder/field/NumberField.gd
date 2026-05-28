@tool
class_name JEP_NumberField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	field = configure_input(SpinBox.new()) as SpinBox
	
	field.step = instruction._step
	if typeof(event.get(property)) == TYPE_INT || instruction._rounded:
		field.rounded = true
		field.step = roundi(field.step)
	
	if instruction._has_range:
		field.min_value = instruction._range_min
		field.max_value = instruction._range_max
	
	field.set_value_no_signal(event.get(property))
	return field

func _on_value_changed() -> void:
	var value : float = event.get(property)
	field.set_value_no_signal(value)

func _connection_status_updated(connected : bool) -> void:
	field.set(&"editable", !connected)
	field.visible = !connected
