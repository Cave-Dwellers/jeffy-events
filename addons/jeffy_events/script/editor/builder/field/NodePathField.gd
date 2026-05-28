@tool
class_name JEP_NodePathField extends JEP_EventField

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	super._create_from_instruction(instruction, node)
	var value : NodePath = event.get(property) as NodePath
	field = configure_input(Button.new()) as Button
	
	field.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS_FORCE
	field.pressed.connect(EditorInterface.popup_node_selector.bind(_set_value, instruction._scope))
	
	# Update the display with our saved value
	_on_value_changed()
	
	return field

func _on_value_changed() -> void:
	var new_path : NodePath = event.get(property)
	
	if !new_path.is_empty():
		field.text = new_path.get_name(new_path.get_name_count() - 1)
		field.tooltip_text = new_path
	else:
		field.text = &"Assign..."

func _connection_status_updated(connected : bool) -> void:
	field.set(&"disabled", connected)
	field.visible = !connected
