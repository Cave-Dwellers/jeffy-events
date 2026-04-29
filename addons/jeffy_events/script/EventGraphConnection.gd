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

@export_storage var from_uuid : StringName
@export_storage var from_port : int
@export_storage var to_uuid : StringName
@export_storage var to_port : int

@export_storage var type : Type

func _init(
	p_from_uuid : StringName = &"", 
	p_from_port : int = 0, 
	p_to_uuid : StringName = &"", 
	p_to_port : int = 0, 
	p_type : int = 0) -> void:
		
	from_uuid = p_from_uuid
	from_port = p_from_port
	to_uuid = p_to_uuid
	to_port = p_to_port
	type = p_type

## Returns true if provided arguments equal the values in this resource
func equals(p_from_uuid : StringName, p_from_port : int, p_to_uuid : StringName, p_to_port : int) -> bool:
	return from_uuid == p_from_uuid\
		&& from_port == p_from_port\
		&& to_uuid == p_to_uuid\
		&& to_port == p_to_port

## Returns true if the connection is data, rather than flow
func is_data() -> bool:
	return type == Type.Data
