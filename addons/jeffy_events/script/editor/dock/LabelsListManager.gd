@tool
class_name JEP_LabelsListManager extends JEP_AbstractListManager

@export var line_edit : LineEdit 
@export var add_button : Button

var name_to_element : Dictionary[String, Control] = {}

func _dock_ready() -> void:
	set_element_mode(false)

func _on_graph_focused(p_graph : JEP_EventGraph) -> void:
	super._on_graph_focused(p_graph)
	
	for entry : Node in entry_container.get_children():
		entry.queue_free()
	name_to_element.clear()
	
	if !graph:
		set_element_mode(false)
		return
	set_element_mode(true)
	
	for label : StringName in graph._labels:
		line_edit.text = label
		_on_add()
	line_edit.text = ""

func _text_submitted(_text : String) -> void:
	_add_label()

func _add_label() -> void:
	if !graph:
		return
		
	if line_edit.text.is_empty() || graph.has_label(line_edit.text):
		JEP_Print.toast_warn("Cannot add a duplicate label!")
		return
	
	var params : Dictionary = {
		"label" : line_edit.text
	}
	
	undo_redo.create_action("Add label")
	undo_redo.add_do_method(_add.bind(params))
	undo_redo.add_undo_method(_remove.bind(params))
	undo_redo.commit_action()

func _add(params : Dictionary) -> void:
	var label : String = params["label"]
	
	if graph.add_label(label):
		line_edit.text = label
		_on_add()

func _remove(params : Dictionary) -> void:
	var label : String = params["label"]
	
	if graph.remove_label(label):
		name_to_element[label].queue_free()
		name_to_element.erase(label)

func _configure_new_entry(instance : Control) -> void:
	var i_line := instance.get_node("Label") as LineEdit
	var i_button := instance.get_node("Button") as Button
	var label : StringName = line_edit.text
	
	i_line.text = label
	i_button.pressed.connect(_on_remove.bind(label))
	
	name_to_element[label] = instance
	line_edit.text = ""

func _on_remove(label : StringName) -> void:
	var params : Dictionary = {
		"label" : label
	}
	
	undo_redo.create_action("Remove label")
	undo_redo.add_do_method(_remove.bind(params))
	undo_redo.add_undo_method(_add.bind(params))
	undo_redo.commit_action()

func set_element_mode(mode : bool) -> void:
	add_button.disabled = !mode
	line_edit.editable = mode
