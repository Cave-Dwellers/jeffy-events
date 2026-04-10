@tool
class_name JEP_EventGraphPool extends Node

## Keeps track of currently open [class JEP_EventGraph]
## in the frontend

signal graph_added(graph : JEP_EventGraph)
signal graph_removed(graph : JEP_EventGraph)
signal graph_saved(graph : JEP_EventGraph)

var _graphs : Array[JEP_EventGraph] = []
var _pending_save : Array[bool] = []

func add_graph(graph : JEP_EventGraph) -> void:
	_graphs.append(graph)
	_pending_save.append(false)
	
	graph.changed.connect(_graph_changed.bind(graph))
	graph_added.emit(graph)

func remove_graph(graph : JEP_EventGraph) -> void:
	var indice := get_indice(graph)
	if indice == -1:
		printerr("JEP_EventGraphPool::remove_graph | Graph does not contain provided event")
		return
	
	_graphs.remove_at(indice)
	_pending_save.remove_at(indice)
	
	graph.changed.disconnect(_graph_changed)
	graph_removed.emit(graph)

func get_indice(graph : JEP_EventGraph) -> int:
	return _graphs.find(graph)

func _graph_changed(graph : JEP_EventGraph) -> void:
	var indice := get_indice(graph)
	if indice == -1:
		return
	
	_pending_save[indice] = true

func _on_save_request() -> void:
	for i in range(_graphs.size()):
		if !_pending_save[i]:
			continue
		
		var graph := _graphs[i]
		ResourceSaver.save(graph, graph.resource_path)
		graph_saved.emit(graph)
		
		# No longer pending save
		_pending_save[i] = false
