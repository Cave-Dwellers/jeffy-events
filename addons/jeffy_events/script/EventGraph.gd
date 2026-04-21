@tool
class_name JEP_EventGraph extends Resource

## Represents a set of events and how they are connected to eachother

signal event_added(event : JEP_Event)
signal event_removed(event : JEP_Event, indice : int)

signal label_added(label : StringName)
signal label_removed(label : StringName)

signal connection_added()
signal connection_removed(at : int)

#signal variable_added(variable : VariableDefinition)
#signal variable_removed(variable : VariableDefinition)

## Events that are present in the graph
@export_storage var _events : Array[JEP_Event]
## Labels that are present in the graph
@export_storage var _labels : Array[StringName]
## Variables that are present in the graph
#@export_storage var _variables : Array[VariableDefinition]
## Connections between events
@export_storage var _connections : Array[JEP_EventGraphConnection]

## Adds [param event] with the position [param at] to the event arary.
func add_event(event : JEP_Event, at : Vector2 = Vector2.ZERO) -> void:
	_events.append(event)
	event.position = at
	event.changed.connect(emit_changed)
	
	event_added.emit(event)
	emit_changed()

## Removes [param event] from the event array (if it exists)
func remove_event(event : JEP_Event) -> void:
	var at : int = get_event_indice(event)
	var before : int = _events.size()
	
	if at == -1:
		printerr("Could not find provided event %s" % event)
		return
	
	remove_connections(at)
	_events.remove_at(at)
	event_removed.emit(event, at)
	emit_changed()

## Removes an event located at [param indice] in the event array
func remove_event_at(indice : int) -> void:
	if _events.size() <= indice:
		printerr("Tried to erase event id %0d, out of bounds!" % indice)
		return
	
	var event := _events.pop_at(indice)
	
	event_removed.emit(event)
	emit_changed()

## Returns true if [param type] matches any event types contained
## in this graph
func has_event_type(type : StringName) -> bool:
	for event : JEP_Event in _events:
		if event.is_class(type):
			return true
	return false

## Gets the indice where [param event] is located. If it doesnt exist in the
## graph, it will return -1 instead.
func get_event_indice(event : JEP_Event) -> int:
	return _events.find(event)

## Adds [param label] to the graph, if it doesn't already exist
func add_label(label : StringName) -> void:
	if !has_label(label):
		_labels.append(label)
		
		label_added.emit(label)
		emit_changed()

## Removes [param label] from the graph, if it exists
func remove_label(label : StringName) -> void:
	if has_label(label):
		_labels.erase(label)
		
		label_removed.emit(label)
		emit_changed()

## Returns true if this graph contains [param label]
func has_label(label : StringName) -> bool:
	return _labels.any(
		func(l : StringName) -> bool: return l == label)

## Adds a new connection to this graph. [param type] determines the connection
## type
func add_connection(from_event : int, from_port : int, to_event : int, to_port : int, type : JEP_EventGraphConnection.Type) -> void:
	var size : int = _events.size()
	if from_event >= size || from_event < 0 || to_event >= size || to_event < 0:
		printerr("Invalid connection attempt | %d %d %d %d" % [from_event, from_port, to_event, to_port])
		return
	
	var connection : JEP_EventGraphConnection = JEP_EventGraphConnection.new(from_event, from_port, to_event, to_port, type)
	event_removed.connect(connection.connection_broken)
	_connections.append(connection)
	print(_connections)
	emit_changed()

## Removes a connection that matches the provided arguments, if it exists
func remove_connection(from_event : int, from_port : int, to_event : int, to_port : int) -> void:
	var at := get_connection_indice(from_event, from_port, to_event, to_port)	
	if at == -1:
		return
	
	_connections.remove_at(at)
	emit_changed()

## Removes connections associated with [param event_indice]. Shifts affected
## connections back one
func remove_connections(event_indice : int) -> void:
	var filtered : Array = _connections.filter(
		func(connection : JEP_EventGraphConnection) -> bool:
			return  connection.from_event == event_indice || \
					connection.to_event == event_indice
	)
	
	if filtered.size() == _connections.size():
		return
	
	_connections = filtered
	emit_changed()

## Gets an [JEP_EventGraphConnection] object that matches the 
## provided arguments, if one exists
func get_connection(from_event : int, from_port : int, to_event : int, to_port : int) -> JEP_EventGraphConnection:
	for connection : JEP_EventGraphConnection in _connections:
		if !connection.equals(from_event, from_port, to_event, to_port):
			continue
		return connection
	return null

## Gets the indice of an [JEP_EventGraphConnection] object that matches the 
## provided arguments, if one exists
func get_connection_indice(from_event : int, from_port : int, to_event : int, to_port : int) -> int:
	for i : int in range(_connections.size()):
		var connection : JEP_EventGraphConnection = _connections[i]
		if !connection.equals(from_event, from_port, to_event, to_port):
			continue
		return i
	return -1

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
