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
@export_storage var events : Array[JEP_Event]
## Labels that are present in the graph
@export_storage var labels : Array[StringName]
## Variables that are present in the graph
@export_storage var variables : Array[VariableDefinition]
## Connections between events
@export_storage var connections : Dictionary

## Adds [arg label] to the graph, if it doesn't already exist
func add_label(label : StringName) -> void:
	if !has_label(label):
		labels.append(label)
		label_added.emit(label)

## Removes [arg label] from the graph, if it exists
func remove_label(label : StringName) -> void:
	if has_label(label):
		labels.erase(label)
		label_removed.emit(label)

## Returns true if this graph contains [arg label]
func has_label(label : StringName) -> bool:
	return labels.any(
		func(l : StringName) -> bool: return l == label)

## Adds [arg variable] with [arg type], if it doesn't already exist 
func add_variable(variable : StringName, type : int) -> void:
	if !has_variable(variable):
		var def := VariableDefinition.new(variable, type)
		variables.append(def)
		variable_added.emit(def)

## Removes [arg variable] from the graph, if it exists
func remove_variable(variable : StringName) -> void:
	if has_variable(variable):
		var at := variables.find_custom(func(v : VariableDefinition) -> bool: return v.name == variable)
		var def := variables.pop_at(at)
		variable_removed.emit(def)

## Returns true if this graph contains [arg variable]
func has_variable(variable : StringName) -> bool:
	return variables.any(
		func(v : VariableDefinition) -> bool: return v.name == variable)

class VariableDefinition extends Resource:
	
	## A definition of a variable
	
	var name : StringName
	var type : int
	
	func _init(p_name : StringName, p_type : int) -> void:
		self.name = p_name
		self.type = p_type
