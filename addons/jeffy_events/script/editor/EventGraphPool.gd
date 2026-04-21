@tool
class_name JEP_EventGraphPool extends Node

## Keeps track of currently open [class JEP_EventGraph]
## in the frontend

signal graph_added(graph : JEP_EventGraph)
signal graph_removed(graph : JEP_EventGraph)
signal graph_replaced(old : JEP_EventGraph, new : JEP_EventGraph)
signal graph_saved(graph : JEP_EventGraph)

var _graphs : Dictionary[String, Entry] = {}

func _dock_ready() -> void:
	# Monitor file system changes
	var fs := EditorInterface.get_file_system_dock()
	fs.resource_removed.connect(_on_resource_removed)
	fs.files_moved.connect(_on_file_moved)

func open_graph(path : String) -> void:
	var graph : Variant = load(path)
	
	if graph is not JEP_EventGraph:
		JEP_Print.toast_error("Invalid or corrupt graph file! %s" % path)
		return
	
	JEP_Print.info("Opened graph at %s" % path)
	add_graph(graph)

func add_graph(graph : JEP_EventGraph) -> void:
	if has(graph):
		JEP_Print.info("Replacing graph in pool")
		var old_entry := _graphs[graph.resource_path]
		_graphs[graph.resource_path] = Entry.new(graph)
		graph_replaced.emit(old_entry.graph, graph)
	else:
		JEP_Print.info("Adding graph to pool")
		_graphs[graph.resource_path] = Entry.new(graph)
		graph_added.emit(graph)
		
	_handle_graph_connection(graph)

func remove_graph(graph : JEP_EventGraph) -> void:
	if !has(graph):
		JEP_Print.error("Graph not in graph pool!")
		return
	
	_graphs.erase(graph.resource_path)
	graph.changed.disconnect(_graph_changed)
	graph_removed.emit(graph)

func save_graph(graph : JEP_EventGraph) -> bool:
	if !has(graph):
		JEP_Print.error("Graph not in graph pool!")
		return false
	
	var entry : Entry = _graphs[graph.resource_path]
	return _save_entry(entry)
	
func save_all_graphs() -> void:
	var graphs_saved : int = 0
	
	for entry : Entry in _graphs.values():
		if _save_entry(entry):
			graphs_saved += 1
	
	if graphs_saved > 0:
		JEP_Print.toast_info("Saved %d graph%s." % [graphs_saved, "s" if graphs_saved > 1 else ""])

func has(graph : JEP_EventGraph) -> bool:
	if _graphs.has(graph.resource_path):
		return true
	return false

func _graph_changed(graph : JEP_EventGraph) -> void:
	if !has(graph):
		return
	
	_graphs[graph.resource_path].pending_save = true

func _handle_graph_connection(graph : JEP_EventGraph, connect : bool = true) -> void:
	if connect:
		if !graph.changed.is_connected(_graph_changed):
			graph.changed.connect(_graph_changed.bind(graph))
			for event : JEP_Event in graph._events:
				event.changed.connect(graph.emit_changed)
	else:
		if graph.changed.is_connected(_graph_changed):
			graph.changed.disconnect(_graph_changed)
			for event : JEP_Event in graph._events:
				event.changed.disconnect(graph.emit_changed)
	
func _save_entry(entry : Entry) -> bool:
	# Do not save unmodified graphs
	if !entry.pending_save:
		return false
	var result : bool = ResourceSaver.save(entry.graph) == OK
	
	if result:
		entry.pending_save = false
		graph_saved.emit(entry.graph)
	else:
		JEP_Print.toast_error("Something went wrong when saving graph %s" % entry.graph.resource_path)
	return result

## Monitoring when graph files are removed
func _on_resource_removed(resource : Resource) -> void:
	if resource is not JEP_EventGraph:
		return
	
	remove_graph(resource)

func _on_file_moved(old : String, new : String) -> void:
	var file : Variant = load(new)
	if file is not JEP_EventGraph:
		return
	
	if !_graphs.has(old):
		return
	
	var graph := _graphs[old]
	_graphs[new] = graph

class Entry extends RefCounted:
	var graph : JEP_EventGraph
	var pending_save : bool = false
	
	func _init(p_graph : JEP_EventGraph = null) -> void:
		self.graph = p_graph
