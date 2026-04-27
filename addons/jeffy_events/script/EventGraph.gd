@tool
class_name JEP_EventGraph extends Resource

## Represents a set of events and how they are connected to eachother

signal event_added(event : JEP_Event, uuid : StringName)
signal event_removed(event : JEP_Event, uuid : StringName)

signal label_added(label : StringName)
signal label_removed(label : StringName)

signal connection_added(connection : JEP_EventGraphConnection)
signal connection_removed(connection : JEP_EventGraphConnection)

#signal variable_added(variable : VariableDefinition)
#signal variable_removed(variable : VariableDefinition)

## Events that are present in the graph (event UUID -> event)
@export_storage var _events : Dictionary[StringName, JEP_Event]
## Labels that are present in the graph
@export_storage var _labels : Array[StringName]
## Variables that are present in the graph
#@export_storage var _variables : Array[VariableDefinition]
## Connections between events (event UUID -> array of outgoing connections)
@export_storage var _connections : Dictionary[StringName, Array]

## Adds [param event] with the position [param at] to the event arary.
func add_event(event : JEP_Event, at : Vector2 = Vector2.ZERO) -> void:
	var uuid : StringName = JEP_UUID.v4()
	
	if at != Vector2.ZERO:
		event.position = at
	
	if _events.set(uuid, event):
		event.changed.connect(emit_changed)
		event_added.emit(event, uuid)
		emit_changed()

func add_events(events : Array[JEP_Event]) -> void:
	for event : JEP_Event in events:
		add_event(event)

## Removes [param event] from the event dictionary (if it exists)
func remove_event(event : JEP_Event) -> void:
	var uuid : StringName = get_event_uuid(event)
	if uuid == null || uuid.is_empty():
		printerr("Could not find provided event %s" % event)
		return
	remove_event_from_uuid(uuid)

## Removes an event located at [param uuid] in the event dictionary (if it exists)
func remove_event_from_uuid(uuid : StringName) -> void:
	var event : JEP_Event = _events.get(uuid)
	if _events.erase(uuid):
		remove_connections(uuid)
		event_removed.emit(event, uuid)
		emit_changed()

## Returns true if [param type] matches any event types contained
## in this graph
func has_event_type(type : StringName) -> bool:
	for event : JEP_Event in _events.values():
		if event.is_class(type):
			return true
	return false

## Gets the UUID where [param event] is stored. If it doesnt exist in the
## graph, it will return null instead
func get_event_uuid(event : JEP_Event) -> StringName:
	var value : Variant = _events.find_key(event)
	if value is StringName:
		return value
	return &"" 

## Adds [param label] to the graph, if it doesn't already exist
func add_label(label : StringName) -> bool:
	if !has_label(label):
		_labels.append(label)
		
		label_added.emit(label)
		emit_changed()
		return true
	return false

## Removes [param label] from the graph, if it exists
func remove_label(label : StringName) -> bool:
	if has_label(label):
		_labels.erase(label)
		
		label_removed.emit(label)
		emit_changed()
		return true
	return false

## Returns true if this graph contains [param label]
func has_label(label : StringName) -> bool:
	return _labels.any(
		func(l : StringName) -> bool: return l == label)

## Adds a new connection to this graph. [param type] determines the connection
## type
func add_connection(from_uuid : StringName, from_port : int, to_uuid : StringName, to_port : int, type : JEP_EventGraphConnection.Type) -> void:
	var size : int = _events.size()
	if !_events.has(from_uuid) || !_events.has(to_uuid):
		printerr("Invalid connection attempt | %d %d %d %d" % [from_uuid, from_port, to_uuid, to_port])
		return
	
	var connection : JEP_EventGraphConnection = JEP_EventGraphConnection.new(from_uuid, from_port, to_uuid, to_port, type)
	if !_connections.has(from_uuid):
		_connections.set(from_uuid, [])
		
	_connections[from_uuid].append(connection)
	connection_added.emit(connection)
	emit_changed()

## Removes a connection that matches the provided arguments, if it exists
func remove_connection(from_uuid : StringName, from_port : int, to_uuid : StringName, to_port : int) -> void:
	var connection : JEP_EventGraphConnection = get_connection(from_uuid, from_port, to_uuid, to_port)	
	if !connection:
		return
	
	remove_connection_object(from_uuid, connection)

func remove_connection_object(uuid : StringName, connection : JEP_EventGraphConnection) -> void:
	_connections[uuid].erase(connection)
	connection_removed.emit(connection)
	emit_changed()

## Removes connections associated with [param uuid].
func remove_connections(uuid : StringName) -> void:
	# Remove connections going into uuid
	var connections_to : Dictionary[StringName, Array] = get_connections_to(uuid)
	for c_uuid : StringName in connections_to.keys():
		for connection : JEP_EventGraphConnection in connections_to[c_uuid]:
			remove_connection_object(c_uuid, connection)
		if _connections[c_uuid].is_empty():
			_connections.erase(c_uuid)
	
	# Remove connections originating from uuid
	var connections_from : Array = _connections.get(uuid, [])
	for connection : JEP_EventGraphConnection in connections_from:
		connection_removed.emit(connection)
	
	_connections.erase(uuid)
	emit_changed()
	
## Gets an [JEP_EventGraphConnection] object that matches the 
## provided arguments, if one exists
func get_connection(from_uuid : StringName, from_port : int, to_uuid : StringName, to_port : int) -> JEP_EventGraphConnection:
	if !_connections.has(from_uuid):
		return null
	var array : Array = _connections.get(from_uuid)
	
	for connection : JEP_EventGraphConnection in array:
		if !connection.equals(from_uuid, from_port, to_uuid, to_port):
			continue
		return connection
	return null

## Returns a list of event UUIDs that are connected to [param uuid].
func get_connections_to(uuid : StringName) -> Dictionary[StringName, Array]:
	var uuids : Dictionary[StringName, Array] = {}
	for array : Array in _connections.values():
		for connection : JEP_EventGraphConnection in array:
			if connection.to_uuid != uuid:
				continue
			
			if !uuids.has(connection.from_uuid):
				uuids[connection.from_uuid] = []
			uuids[connection.from_uuid].append(connection)
	return uuids

### Adds [param variable] with [param type], if it doesn't already exist 
#func add_variable(variable : StringName, type : int) -> void:
	#if !has_variable(variable):
		#var def : VariableDefinition = VariableDefinition.new(variable, type)
		#_variables.append(def)
		#
		#variable_added.emit(def)
		#emit_changed()
#
### Removes [param variable] from the graph, if it exists
#func remove_variable(variable : StringName) -> void:
	#if has_variable(variable):
		#var at : int = _variables.find_custom(func(v : VariableDefinition) -> bool: return v.name == variable)
		#var def : StringName = _variables.pop_at(at)
		#
		#variable_removed.emit(def)
		#emit_changed()
#
### Returns true if this graph contains [param variable]
#func has_variable(variable : StringName) -> bool:
	#return _variables.any(
		#func(v : VariableDefinition) -> bool: return v.name == variable)
#
#class VariableDefinition extends Resource:
	#
	### A definition of a variable
	#
	#var name : StringName
	#var type : int
	#
	#func _init(p_name : StringName, p_type : int) -> void:
		#self.name = p_name
		#self.type = p_type
