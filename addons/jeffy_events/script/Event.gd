@abstract @tool
class_name JEP_Event extends Resource

## An abstract interface that is provided
## a custom context object at runtime.

## Base instruction handlers, used by built in events
const NODE := preload("uid://mewxu2y1d8q2")
const ELEMENT := preload("uid://b0rgkngbx133o")

## The position of this event in an [class EventGraph]
@export_storage var position : Vector2 :
	set(value) :
		position = value
		emit_changed()

@abstract
## Method called by [class EventGraphExecutor] when this
## event is reached in an [clas EventGraph]. The argument
## may be null depending on how the Event is being called
func _event(ctx : Object = null) -> int

#@abstract
### Method called by [JEP_EventGraphExecutor] when data
### on a port needs to be resolved.
#func _resolve_data(variable : StringName) -> Variant

@abstract
func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction

## Returns the human readable name of this event.
func _get_name() -> StringName:
	return get_class()

## Returns a description that describes this event.
func _get_description() -> StringName:
	return &""

## Returns true if this event is only a data holder,
## meaning that it does not contain any flow ports.
## This is used to determine whether or not data exchange
## is immediate (pull) or if it is lazy (cached)
func is_data() -> bool:
	return false

## Returns the class name of this script
func get_class() -> String:
	var script : Script = get_script()
	return script.get_global_name()

## Returns true if [param clazz] matches or inherits this class
func is_class(clazz : String) -> bool:
	var script : Script = get_script()
	
	if self is not JEP_Event:
		return clazz == script.get_global_name() || super.is_class(clazz)
	return clazz == script.get_global_name()
