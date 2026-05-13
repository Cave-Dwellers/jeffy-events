@tool
class_name JEP_LabelsListManager extends JEP_AbstractListManager

@export var line_edit : LineEdit 
@export var add_button : Button

var graph : JEP_EventGraph

func _dock_ready() -> void:
	set_element_mode(false)

func _on_graph_focused(p_graph : JEP_EventGraph) -> void:
	graph = p_graph
	for entry : Node in entry_container.get_children():
		entry.queue_free()
	
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
		
	if line_edit.text.is_empty():
		JEP_Print.toast_warn("Cannot add a duplicate label!")
		return
	
	if graph.add_label(line_edit.text):
		JEP_Print.info("Added label %s" % line_edit.text)
		_on_add()

func _configure_new_entry(instance : Control) -> void:
	var i_line := instance.get_node("Label") as LineEdit
	var i_button := instance.get_node("Button") as Button
	var label : StringName = line_edit.text
	
	i_line.text = label
	i_button.pressed.connect(_on_remove.bind(instance, label))
	line_edit.text = ""

func _on_remove(instance : Control, label : StringName) -> void:
	if graph.remove_label(label):
		instance.queue_free()
		JEP_Print.info("Removed label %s" % label)

func set_element_mode(mode : bool) -> void:
	add_button.disabled = !mode
	line_edit.editable = mode
