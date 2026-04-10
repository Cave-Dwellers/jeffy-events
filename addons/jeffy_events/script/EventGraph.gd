@tool
class_name JEP_EventGraph extends Resource

## Represents a set of events and how they are connected to eachother

signal event_added(event : JEP_Event)
signal event_removed(event : JEP_Event)

signal label_added(label : StringName)
signal label_removed(label : StringName)

signal variable_added(variable : VariableDefinition)
signal variable_removed(variable : VariableDefinition)

## Events that are present in the graph
@export_storage var _events : Array[JEP_Event]
## Labels that are present in the graph
@export_storage var _labels : Array[StringName]
## Variables that are present in the graph
@export_storage var _variables : Array[VariableDefinition]
## Connections between events
@export_storage var connections : Dictionary

## Adds [arg event] with the position [arg at] to the event arary.
func add_event(event : JEP_Event, at : Vector2 = Vector2.ZERO) -> void:
	_events.append(event)
	event.position = at
	
	event_added.emit(event)
	emit_changed()

## Removes [arg event] from the event array
func remove_event(event : JEP_Event) -> void:
	var before : int = _events.size()
	_events.erase(event)
	if before != _events.size():
		event_removed.emit(event)
		emit_changed()

## Removes an event located at [arg indice] in the event array
func remove_event_at(indice : int) -> void:
	if _events.size() <= indice:
		printerr("Tried to erase event id %0d, out of bounds!" % indice)
		return
	
	var event := _events.pop_at(indice)
	
	event_removed.emit(event)
	emit_changed()

func has_event_type(type : GDScript) -> void:
	pass

## Adds [arg label] to the graph, if it doesn't already exist
func add_label(label : StringName) -> void:
	if !has_label(label):
		_labels.append(label)
		
		label_added.emit(label)
		emit_changed()

## Removes [arg label] from the graph, if it exists
func remove_label(label : StringName) -> void:
	if has_label(label):
		_labels.erase(label)
		
		label_removed.emit(label)
		emit_changed()

## Returns true if this graph contains [arg label]
func has_label(label : StringName) -> bool:
	return _labels.any(
		func(l : StringName) -> bool: return l == label)

## Adds [arg variable] with [arg type], if it doesn't already exist 
func add_variable(variable : StringName, type : int) -> void:
	if !has_variable(variable):
		var def : VariableDefinition = VariableDefinition.new(variable, type)
		_variables.append(def)
		
		variable_added.emit(def)
		emit_changed()

## Removes [arg variable] from the graph, if it exists
func remove_variable(variable : StringName) -> void:
	if has_variable(variable):
		var at : int = _variables.find_custom(func(v : VariableDefinition) -> bool: return v.name == variable)
		var def : StringName = _variables.pop_at(at)
		
		variable_removed.emit(def)
		emit_changed()

## Returns true if this graph contains [arg variable]
func has_variable(variable : StringName) -> bool:
	return _variables.any(
		func(v : VariableDefinition) -> bool: return v.name == variable)

class VariableDefinition extends Resource:
	
	## A definition of a variable
	
	var name : StringName
	var type : int
	
	func _init(p_name : StringName, p_type : int) -> void:
		self.name = p_name
		self.type = p_type
