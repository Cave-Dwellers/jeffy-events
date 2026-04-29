class_name JEP_EventGraphPlayer extends Node

## Handles playback of a [JEP_EventGraph]

signal finished()

@export var graph : JEP_EventGraph

var completed_uuids : Array[StringName] = []

## Can be overwritten in a super class to provide a "context object" to all
## events. See markdown docs for more info
func get_context_object() -> Object:
	return null

func play(label : String = "") -> void:
	if !graph:
		push_warning("%s | No graph provided" % name)
		return
	
	var copy : JEP_EventGraph = graph.duplicate()
	var start : StringName
	
	for uuid : StringName in graph._events.keys():
		var event : JEP_Event = graph._events[uuid]
		if event is not EventLabel:
			continue
		
		event = event as EventLabel
		if event.label == label:
			start = uuid
			break
	
	if !start:
		push_warning("%s | Label %s does not exist in graph" % [name, label])
		return
	
	_execute(copy, start)

#region Internal

func _execute(e_graph : JEP_EventGraph, uuid : StringName) -> void:
	var event : JEP_Event = e_graph._events[uuid]
	_resolve_data(e_graph, uuid)
	
	var out_port : int = await event._event(get_context_object())
	completed_uuids.append(uuid)
	_traverse(out_port, e_graph, uuid)

func _resolve_data(e_graph : JEP_EventGraph, uuid : StringName, visited : Array = []) -> void:
	if uuid in visited:
		return
	visited.append(uuid)
	
	var event : JEP_Event = e_graph._events[uuid]
	var data_connections := e_graph.get_data_connections_to(uuid)
	
	for connection : JEP_EventGraphConnection in data_connections:
		var from_event : JEP_Event = e_graph._events[connection.from_uuid]
		
		if from_event.is_data():
			# If the event says its just data, we can recursively calculate
			_resolve_data(e_graph, connection.from_uuid, visited)
		else:
			# Otherwise, we should warn if the event has not been
			# processed just yet before pulling whatever data is
			# present
			if !completed_uuids.has(connection.from_uuid):
				push_warning("[JeffyEvents] Data pull form unprocessed %s event" % from_event._get_name())
		
		var data : Variant = from_event._pull_data(connection.from_port)
		event._accept_data(connection.to_port, data)

func _traverse(port : int, e_graph : JEP_EventGraph, from_uuid : StringName) -> void:
	var from_event : JEP_Event = e_graph._events[from_uuid]
	var connections : Array = e_graph._connections.get(from_uuid, [])
	var next_uuid : StringName
	
	if connections.is_empty() || from_event is EventTerminator:
		finished.emit()
		return
	
	for connection : JEP_EventGraphConnection in connections:
		if connection.from_port == port:
			next_uuid = connection.to_uuid
			break
	
	if !next_uuid:
		push_error("%s | Invalid or missing connection on %s, port %d" % [name, from_event._get_name(), port])
		return
	
	_execute(e_graph, next_uuid)

#endregion
