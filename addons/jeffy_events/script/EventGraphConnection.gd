@tool
class_name JEP_EventGraphConnection extends Resource

## A connection between two [JEP_Event] in an [JEP_EventGraph]
##
## An object that holds connection data between two events within an event graph.
## Connections do not have direct references to events, rather they use
## indices to point at events in a graph resource. This is to prevent cyclic
## dependency issues

enum Type {
	Flow,
	Data
}

@export_storage var from_event : int
@export_storage var from_port : int
@export_storage var to_event : int
@export_storage var to_port : int
@export_storage var type : Type

func _init(p_from_event : int = 0, p_from_port : int = 0, p_to_event : int = 0, p_to_port : int = 0, p_type : int = 0) -> void:
	from_event = p_from_event
	from_port = p_from_port
	to_event = p_to_event
	to_port = p_to_port
	type = p_type

## Returns true if provided arguments equal the values in this resource
func equals(p_from_event : int, p_from_port : int, p_to_event : int, p_to_port : int) -> bool:
	return from_event == p_from_event \
		&& from_port == p_from_port\
		&& to_event == p_to_event\
		&& to_port == p_to_port

## Called whenever an event is removed from the graph; shifts indices if
## the event removed comes before associated event indices in this resource
func connection_broken(event : JEP_Event, event_indice : int) -> void:
	if event_indice < from_event:
		from_event -= 1
	if event_indice < to_event:
		to_event -= 1
