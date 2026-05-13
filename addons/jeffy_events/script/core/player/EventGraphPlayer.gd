class_name JEP_EventGraphPlayer extends Node

## Handles playback of a [JEP_EventGraph]

signal finished()

@export var graph : JEP_EventGraph

var _context_object : JEP_GraphContext
var _completed_uuids : Array[StringName] = []
var _variables : Dictionary[StringName, Variant] = {}

## Can be overwritten in a super class to provide a "context object" to all
## events. See markdown docs for more info
func get_context_object() -> JEP_GraphContext:
	if !_context_object:
		_context_object = JEP_GraphContext.new(self)
	return _context_object

## Assigns a variable dictionary to this graph player. The dictionary is
## made read-only once it is bound 
func bind_variables(variables : Dictionary[StringName, Variant]) -> void:
	_variables = variables
	_variables.make_read_only()

## Plays an event graph starting at [param label]. Variables can be provided
## if the graph requires them
func play(label : String = "", variables : Dictionary[StringName, Variant] = {}) -> void:
	if !graph:
		push_warning("%s | No graph provided" % name)
		return
	
	if Engine.is_editor_hint() || OS.has_feature(&"debug"):
		_verify_variables(variables)
	bind_variables(variables)
	
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

## Throws assertions if variables are missing, throwaway, or improperly supplied
func _verify_variables(variables : Dictionary[StringName, Variant] = {}) -> void:
	var to_supply : Array[String] = []
	for v : JEP_EventGraphVariable in graph._variables:
		# Add to list
		to_supply.append(v.name)
		
		# Variable should be supplied
		assert(variables.has(v.name), "%s | Variable %s is not supplied" % [name, v.name])
		if !variables.has(v.name):
			continue
		
		# Variable data should match the data type
		var data : Variant = variables.get(v.name);
		assert(typeof(data) == v.type, "%s | Variable %s was supplied incorrect data type. %s should be %s instead" % [name, v.name, type_string(typeof(data)), type_string(v.type)])
	
	for key : String in variables.keys():
		# Variable should be defined in graph
		assert(to_supply.has(key), "%s | Variable %s does not exist in graph, consider extending JEP_GraphContext instead" % [name, key])
		
func _execute(e_graph : JEP_EventGraph, uuid : StringName) -> void:
	var event : JEP_Event = e_graph._events[uuid]
	_resolve_data(e_graph, uuid)
	
	var out_port : int = await event._event(get_context_object())
	_completed_uuids.append(uuid)
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
			if !_completed_uuids.has(connection.from_uuid):
				push_warning("[JeffyEvents] Data pull form unprocessed %s event" % from_event._get_name())
		
		var data : Variant = from_event._pull_data(connection.from_port, get_context_object())
		event._accept_data(connection.to_port, data)

func _traverse(port : int, e_graph : JEP_EventGraph, from_uuid : StringName) -> void:
	var from_event : JEP_Event = e_graph._events[from_uuid]
	var connections : Array = e_graph._connections.get(from_uuid, [])
	var next_uuid : StringName
	
	if connections.is_empty() || from_event is EventTerminator:
		_finish()
		return
	
	for connection : JEP_EventGraphConnection in connections:
		if connection.from_port == port:
			next_uuid = connection.to_uuid
			break
	
	if !next_uuid:
		push_error("%s | Invalid or missing connection on %s, port %d" % [name, from_event._get_name(), port])
		return
	
	_execute(e_graph, next_uuid)

func _finish() -> void:
	finished.emit()
	_completed_uuids.clear()
	_context_object = null

#endregion
