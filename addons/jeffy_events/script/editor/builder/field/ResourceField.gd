@tool
class_name JEP_ResourceField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	var value : Resource = event.get(property) as Resource
	field = configure_input(EditorResourcePicker.new()) as EditorResourcePicker
	field.custom_minimum_size.x = 140
	
	if !instruction._scope.is_empty():
		field.base_type = instruction._scope
	field.edited_resource = value
	
	return field

func _on_value_changed() -> void:
	field = field as EditorResourcePicker
	field.edited_resource = event.get(property)

func _connection_status_updated(connected : bool) -> void:
	field.set(&"editable", !connected)
	field.visible = !connected
