@abstract @tool
class_name JEP_AbstractListManager extends Node

@export var graph_undo_redo : JEP_GraphUndoRedo
@export var entry_template : Control
@export var entry_container : Control

var graph : JEP_EventGraph
var undo_redo : UndoRedo :
	get : return graph_undo_redo.get_undo_redo(graph)

func _on_add() -> void:
	var instance := entry_template.duplicate()
	instance.visible = true
	_configure_new_entry(instance)
	entry_container.add_child(instance)

@abstract
func _add(params : Dictionary) -> void

@abstract
func _remove(params : Dictionary) -> void

@abstract
func _configure_new_entry(instance : Control) -> void

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey || !entry_container.is_visible_in_tree() || !graph:
		return
	
	event = event as InputEventKey
	
	if event.is_pressed() && event.is_command_or_control_pressed():
		if event.shift_pressed && event.keycode == KEY_Z:
			graph_undo_redo.redo(graph)
			return
		
		match event.keycode:
			KEY_Z:	graph_undo_redo.undo(graph); return
			KEY_Y:	graph_undo_redo.redo(graph); return

func _on_graph_focused(p_graph : JEP_EventGraph) -> void:
	graph = p_graph
