@tool
class_name JEP_BuiltinInstructionHandler extends JEP_InstructionHandler

func _handle_node_instruction(instruction : JEP_NodeInstruction, node : JEP_EventGraphNode) -> GraphNode:
	var event : JEP_Event = instruction.event
	node.title = event._get_name()
	node.tooltip_text = event._get_description()
	
	return node

func _handle_element_instruction(instruction : JEP_ElementInstruction, event : JEP_Event, node : JEP_EventGraphNode) -> Control:
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

func handle_port_instruction(instruction : JEP_ElementInstruction.Port, node : JEP_EventGraphNode, id : int) -> void:
	# Godot's graph element nodes assign their ports based on child
	# element index
	var type : int = 0
	if instruction is JEP_ElementInstruction.Property:
		type = instruction._get_port_type()
	if instruction is JEP_ElementInstruction.DataSource:
		type = instruction._port_type
	var color : Color = JEP_PortInfo.PortColors[type]
	
	if instruction._has_in:
		node.set_slot_enabled_left(id, true)
		node.set_slot_type_left(id, type)
		node.set_slot_color_left(id, color)
	
	if instruction._has_out:
		node.set_slot_enabled_right(id, true)
		node.set_slot_type_right(id, type)
		node.set_slot_color_right(id, color)

func handle_property_instruction(
	instruction : JEP_ElementInstruction.Property,
	event : JEP_Event,
	node : JEP_EventGraphNode, 
	element : HBoxContainer,
	id : int
	) -> void:
	
	if instruction is JEP_ElementInstruction.Number:
		handle_number_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.Line:
		handle_line_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.CodeLine:
		handle_code_line_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.EnumLine:
		handle_enum_line_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.Bool:
		handle_bool_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.NodePathField:
		handle_node_path_instruction(instruction, node, event, element)
	if instruction is JEP_ElementInstruction.ResourceField:
		handle_resource_instruction(instruction, node, event, element)

func handle_number_instruction(instruction : JEP_ElementInstruction.Number, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_NumberField = JEP_NumberField.new(event, property, undo_redo)
	var input : SpinBox = field._create_from_instruction(instruction, node)
	
	input.value_changed.connect(field._set_value)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func handle_line_instruction(instruction : JEP_ElementInstruction.Line, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_LineField = JEP_LineField.new(event, property, undo_redo)
	var input : LineEdit = field._create_from_instruction(instruction, node)
	
	input.editing_toggled.connect(field.edit_toggled_wrapper)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)
	
func handle_code_line_instruction(instruction : JEP_ElementInstruction.CodeLine, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_CodeLineField = JEP_CodeLineField.new(event, property, undo_redo)
	
	# We want to erase the label, so the code block can take
	# up the full horizontal space
	for child in element.get_children():
		child.queue_free()
	var input : CodeEdit = field._create_from_instruction(instruction, node)
	
	input.focus_exited.connect(field._focus_exited_wrapper)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func handle_enum_line_instruction(instruction : JEP_ElementInstruction.EnumLine, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_EnumLineField = JEP_EnumLineField.new(event, property, undo_redo)
	var input : OptionButton = field._create_from_instruction(instruction, node)
	
	input.item_selected.connect(field._selected_wrapper)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func handle_bool_instruction(instruction : JEP_ElementInstruction.Bool, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_BoolField = JEP_BoolField.new(event, property, undo_redo)
	var input : CheckBox = field._create_from_instruction(instruction, node)
	
	input.toggled.connect(field._set_value)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func handle_node_path_instruction(instruction : JEP_ElementInstruction.NodePathField, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_NodePathField = JEP_NodePathField.new(event, property, undo_redo)
	var input : Button = field._create_from_instruction(instruction, node)
	
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func handle_resource_instruction(instruction : JEP_ElementInstruction.ResourceField, node : JEP_EventGraphNode, event : JEP_Event, element : HBoxContainer) -> void:
	var property : StringName = instruction._property
	var field : JEP_ResourceField = JEP_ResourceField.new(event, property, undo_redo)
	var input : EditorResourcePicker = field._create_from_instruction(instruction, node)
	
	input.resource_changed.connect(field._set_value)
	node.add_connection_listener(element.get_index(), field._connection_status_updated)
	element.add_child(input)

func configure_input(node : Control) -> Control:
	node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node
