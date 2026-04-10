@tool
class_name JEP_EventListController extends ItemList

## Updates list based on [class JEP_EventGraphPool] signals

## Fired when a graph has been selected
signal graph_selected(graph : JEP_EventGraph)

const ICO_GRAPH : Texture2D = preload("res://addons/jeffy_events/asset/icon/EventGraph.svg")

func _on_graph_added(graph : JEP_EventGraph) -> void:
	var idx := add_item(format_path(graph), ICO_GRAPH)
	set_item_metadata(idx, graph)
	graph.changed.connect(_mark_graph_as_unsaved.bind(idx), CONNECT_ONE_SHOT)

func _on_graph_removed(graph : JEP_EventGraph) -> void:
	modify_entry(graph, remove_item)

func _on_graph_saved(graph : JEP_EventGraph) -> void:
	# We're just resetting the file name here
	modify_entry(graph, _mark_graph_as_saved.bind(graph))

func _mark_graph_as_saved(idx : int, graph : JEP_EventGraph) -> void:
	set_item_text(idx, format_path(graph))
	graph.changed.connect(_mark_graph_as_unsaved.bind(idx), CONNECT_ONE_SHOT)

func _on_graph_selected(idx : int) -> void:
	var meta : Variant = get_item_metadata(idx)
	if meta is JEP_EventGraph:
		graph_selected.emit(meta)

func _mark_graph_as_unsaved(idx : int) -> void:
	var with_mark := "%s (*)" % get_item_text(idx) 
	set_item_text(idx, with_mark)

## Calls [arg method] with the first item id that matches [arg graph]
func modify_entry(graph : JEP_EventGraph, method : Callable) -> void:
	for i in range(item_count):
		var meta : Variant = get_item_metadata(i)
		if meta != graph:
			continue
		
		method.call(i)
		break

func format_path(graph : JEP_EventGraph) -> StringName:
	return StringName(graph.resource_path.get_file())
