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

func _handle_element_instruction(instruction : JEP_ElementInstruction, event : JEP_Event, node : GraphNode) -> Control:
	var container : HBoxContainer = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(200, 28)
	
	var label : Label = Label.new()
	label.text = instruction._label
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	node.add_child(container)
	container.add_child(label)
	
	if instruction is JEP_ElementInstruction.Port:
		handle_port_instruction(instruction, node, container.get_index())
	if instruction is JEP_ElementInstruction.Property:
		handle_property_instruction(instruction, event, node, container, container.get_index())
	return container

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
	if instruction is JEP_ElementInstruction.CodeLine:
		handle_code_line_instruction(instruction, event, element)
	if instruction is JEP_ElementInstruction.EnumLine:
		handle_enum_line_instruction(instruction, event, element)
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
			if on:
				return
			
			event.set(property, input.text)
			event.emit_changed()
	)
	
	element.add_child(input)
	
func handle_code_line_instruction(instruction : JEP_ElementInstruction.CodeLine, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var input : CodeEdit = configure_input(CodeEdit.new())
	
	input.size_flags_vertical = 0
	input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	input.scroll_fit_content_height = true
	
	if instruction._flat:
		input.theme_type_variation = &"CodeEditFlat"
	
	if instruction._placeholder_text:
		input.placeholder_text = instruction._placeholder_text
	
	# We want to erase the label, so the code block can take
	# up the full horizontal space
	for child in element.get_children():
		child.queue_free()
	
	input.text = event.get(property) as String
	input.text_changed.connect(
		func() -> void:
			element.size.y = 0
			event.set(property, input.text)
			event.emit_changed()
	)
	
	element.add_child(input)

func handle_enum_line_instruction(instruction : JEP_ElementInstruction.EnumLine, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var value : Variant = event.get(property)
	var input : OptionButton = configure_input(OptionButton.new())
	
	# Enum keys tend to be long, so element should have more
	# priority in sizing
	input.size_flags_stretch_ratio = 1.5
	input.autowrap_mode = TextServer.AUTOWRAP_OFF
	input.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	if instruction._strings.is_empty():
		JEP_Print.error("Strings not provided to EnumLine instruction - %s" % property)
		return
	
	var strings : PackedStringArray = instruction._strings
	for i : int in range(strings.size()):
		var entry : String = strings.get(i)
		input.add_item(entry, i)
		
		if value == entry:
			input.select(input.get_item_index(i))
	
	input.item_selected.connect(
		func(at : int) -> void:
			if at == -1:
				return
			
			event.set(property, input.get_item_text(at))
			event.emit_changed()
	)
	
	# If no default value, select first option in enum
	if input.get_selected_id() == -1:
		input.select(0)
	
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
	
