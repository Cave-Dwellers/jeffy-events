@tool
class_name JEP_VariablesListManager extends JEP_AbstractListManager

const SUPPORTED_TYPES : Array[int] = [
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_BOOL,
	TYPE_STRING,
	TYPE_NODE_PATH,
	TYPE_OBJECT
]

@export var line_edit : LineEdit 
@export var type_dropdown : OptionButton 
@export var add_button : Button

var name_to_element : Dictionary[String, Control] = {}

func _dock_ready() -> void:
	set_element_mode(false)
	
	for type : int in SUPPORTED_TYPES:
		var type_name : String = type_string(type)
		var type_icon : Texture2D = EditorInterface.get_base_control().get_theme_icon(type_name, "EditorIcons")
		
		type_dropdown.add_icon_item(type_icon, type_name.capitalize(), type)

func _on_graph_focused(p_graph : JEP_EventGraph) -> void:
	super._on_graph_focused(p_graph)
	
	for entry : Node in entry_container.get_children():
		entry.queue_free()
	name_to_element.clear()
	
	if !graph:
		set_element_mode(false)
		return
	set_element_mode(true)
	
	for variable : JEP_EventGraphVariable in graph._variables:
		line_edit.text = variable.name
		type_dropdown.select(type_dropdown.get_item_index(variable.type))
		_on_add()
	
	line_edit.text = ""
	type_dropdown.select(0)

func _add_variable() -> void:
	if !graph:
		return
		
	if line_edit.text.is_empty():
		JEP_Print.toast_warn("Cannot add an empty variable!")
		return
	
	var params : Dictionary = {
		"variable" : line_edit.text,
		"type" : type_dropdown.get_item_id(type_dropdown.selected)
	}
	
	undo_redo.create_action("Add variable")
	undo_redo.add_do_method(_add.bind(params))
	undo_redo.add_undo_method(_remove.bind(params))
	undo_redo.commit_action()

func _add(params : Dictionary) -> void:
	var variable_name : String = params["variable"]
	var variable_type : int = params["type"]
	
	if graph.add_variable(variable_name, variable_type):
		line_edit.text = variable_name
		type_dropdown.select(variable_type)
		_on_add()

func _remove(params : Dictionary) -> void:
	var variable_name : String = params["variable"]
	
	if graph.remove_variable(variable_name):
		name_to_element[variable_name].queue_free()
		name_to_element.erase(variable_name)

func _configure_new_entry(instance : Control) -> void:
	var i_line := instance.get_node("Label") as LineEdit
	var i_button := instance.get_node("Button") as Button
	var label : StringName = line_edit.text
	
	i_line.text = label
	i_line.right_icon = type_dropdown.get_item_icon(type_dropdown.selected)
	i_button.pressed.connect(_on_remove.bind(label, type_dropdown.selected), CONNECT_ONE_SHOT)
	
	name_to_element[label] = instance
	line_edit.text = ""

func _on_remove(variable : String, type : int) -> void:
	var params : Dictionary = {
		"variable" : variable,
		"type" : type
	}
	
	undo_redo.create_action("Remove variable")
	undo_redo.add_do_method(_remove.bind(params))
	undo_redo.add_undo_method(_add.bind(params))
	undo_redo.commit_action()

func set_element_mode(mode : bool) -> void:
	add_button.disabled = !mode
	type_dropdown.disabled = !mode
	line_edit.editable = mode
