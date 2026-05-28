@tool
class_name JEP_GraphUndoRedo extends Node

## Generated [UndoRedo] for opened graphs
static var undo_redos : Dictionary[JEP_EventGraph, UndoRedo] = {}

static func get_undo_redo(graph : JEP_EventGraph) -> UndoRedo:
	var ur : UndoRedo = undo_redos.get_or_add(graph, UndoRedo.new())
	return ur

func undo(graph : JEP_EventGraph) -> bool:
	var undo_redo : UndoRedo = get_undo_redo(graph)
	var action : String = undo_redo.get_current_action_name()
	if undo_redo.undo():
		JEP_Print.toast_info("Undo: %s" % action)
		return true
	return false

func redo(graph : JEP_EventGraph) -> bool:
	var undo_redo : UndoRedo = get_undo_redo(graph)
	if undo_redo.redo():
		JEP_Print.toast_info("Redo: %s" % undo_redo.get_current_action_name())
		return true
	return false

func _on_graph_removed(graph : JEP_EventGraph) -> void:
	undo_redos.erase(graph)
