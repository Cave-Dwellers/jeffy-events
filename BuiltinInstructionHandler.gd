@tool
class_name JEP_BuiltinInstructionHandler extends JEP_InstructionHandler

func _handle_node_instruction(instruction : JEP_NodeInstruction, node : GraphNode) -> GraphNode:
	var event : JEP_Event = instruction.event
	node.title = event._get_name()
	node.tooltip_text = event._get_description()
	
	if !instruction.is_static:
		# event.changed...
		pass
	
	#for element_instruction : JEP_ElementInstruction in instruction.elements:
		#var control : Control = Control.new()
		#control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#
		#var element := _handle_element_instruction(element_instruction, event, node, control)
	
	return node

func _handle_element_instruction(instruction : JEP_ElementInstruction, event : JEP_Event, node : GraphNode, element : Control) -> Control:
	var container : HBoxContainer = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	element.custom_minimum_size = Vector2(200, 32)
	container.custom_minimum_size = Vector2(200, 32)
	
	var label : Label = Label.new()
	label.text = instruction._label
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	element.add_child(container)
	container.add_child(label)
	
	if instruction is JEP_ElementInstruction.Port:
		handle_port_instruction(instruction, node, element.get_index())
	if instruction is JEP_ElementInstruction.Property:
		handle_property_instruction(instruction, event, node, container, element.get_index())
	
	return element

func handle_port_instruction(instruction : JEP_ElementInstruction.Port, node : GraphNode, id : int) -> void:
	# Godot's graph element nodes assign their ports based on child
	# element index
	if instruction._has_in:
		node.set_slot_enabled_left(id, true)
	
	if instruction._has_out:
		node.set_slot_enabled_right(id, true)
		node.set_slot_metadata_right(id, instruction._id)

func handle_property_instruction(
	instruction : JEP_ElementInstruction.Property,
	event : JEP_Event,
	node : GraphNode, 
	element : HBoxContainer,
	id : int
	) -> void:
	
	if instruction._has_in:
		var type : int = instruction._get_port_type()
		var color : Color = JEP_EventGraphFrontend.PortColors[type]
		
		node.set_slot_enabled_left(id, true)
		node.set_slot_type_left(id, type)
		node.set_slot_color_left(id, color)
	
	if instruction is JEP_ElementInstruction.Number:
		handle_number_instruction(instruction, event, element)
	if instruction is JEP_ElementInstruction.Line:
		handle_line_instruction(instruction, event, element)
	if instruction is JEP_ElementInstruction.Bool:
		handle_bool_instruction(instruction, event, element)

func handle_number_instruction(instruction : JEP_ElementInstruction.Number, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var input : SpinBox = configure_input(SpinBox.new())
	
	if typeof(event.get(property)) == TYPE_INT || instruction._rounded:
		input.rounded = true
		input.step = roundi(input.step)
	
	if instruction._has_range:
		input.min_value = instruction._range_min
		input.max_value = instruction._range_max
	
	input.set_value_no_signal(event.get(property))
	input.value_changed.connect(
		func(value : int) -> void:
			event.set(property, value)
			event.emit_changed()
	)
	
	element.add_child(input)

func handle_line_instruction(instruction : JEP_ElementInstruction.Line, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var input : LineEdit = configure_input(LineEdit.new())
	
	if instruction._max_character_count != -1:
		input.max_length = instruction._max_character_count
	
	input.text = event.get(property) as String
	input.editing_toggled.connect(
		func(on : bool) -> void:
			if !on:
				return
			
			event.set(property, input.text)
			event.emit_changed()
	)
	
	element.add_child(input)

func handle_bool_instruction(instruction : JEP_ElementInstruction.Bool, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var input : CheckBox = configure_input(CheckBox.new())
	
	input.toggle_mode = true
	input.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	input.button_pressed = event.get(property) as bool
	
	input.toggled.connect(
		func(on : bool) -> void:
			event.set(property, on)
			event.emit_changed()
	)
	
	element.add_child(input)

func configure_input(node : Control) -> Control:
	node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node
	
