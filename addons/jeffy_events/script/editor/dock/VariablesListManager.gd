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

var graph : JEP_EventGraph

func _dock_ready() -> void:
	set_element_mode(false)
	
	for type : int in SUPPORTED_TYPES:
		var type_name : String = type_string(type)
		var type_icon : Texture2D = EditorInterface.get_base_control().get_theme_icon(type_name, "EditorIcons")
		
		type_dropdown.add_icon_item(type_icon, type_name.capitalize(), type)

func _on_graph_focused(p_graph : JEP_EventGraph) -> void:
	graph = p_graph
	for entry : Node in entry_container.get_children():
		entry.queue_free()
	
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
	
	var variable_name : String = line_edit.text
	var variable_type : int = type_dropdown.get_item_id(type_dropdown.selected)
	
	if graph.add_variable(variable_name, variable_type):
		JEP_Print.info("Added variable %s" % line_edit.text)
		_on_add()

func _configure_new_entry(instance : Control) -> void:
	var i_line := instance.get_node("Label") as LineEdit
	var i_button := instance.get_node("Button") as Button
	var label : StringName = line_edit.text
	
	i_line.text = label
	i_line.right_icon = type_dropdown.get_item_icon(type_dropdown.selected)
	i_button.pressed.connect(_on_remove.bind(instance, label))
	
	line_edit.text = ""

func _on_remove(instance : Control, label : StringName) -> void:
	if graph.remove_variable(label):
		instance.queue_free()
		JEP_Print.info("Removed variable %s" % label)

func set_element_mode(mode : bool) -> void:
	add_button.disabled = !mode
	type_dropdown.disabled = !mode
	line_edit.editable = mode
