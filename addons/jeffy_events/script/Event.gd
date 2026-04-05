@abstract @tool
class_name JEP_Event extends Resource

## An abstract interface that is provided
## a custom context object at runtime.

## The position of this event in an [class EventGraph]
@export_storage var position : Vector2

@abstract
## Method called by [class EventGraphExecutor] when this
## event is reached in an [clas EventGraph]. The argument
## may be null depending on how the Event is being called
func _event(ctx : Object = null) -> int

@abstract
## TBD: EGNBuilder and EGNInstructions
func _get_instructions() -> Dictionary

## Returns the human readable name of this event.
func _get_name() -> StringName:
	return (get_script() as Script).get_global_name()

## Returns a description that describes this event.
func _get_description() -> StringName:
	return &""
