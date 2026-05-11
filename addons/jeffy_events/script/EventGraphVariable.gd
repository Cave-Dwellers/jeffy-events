class_name JEP_EventGraphVariable extends Resource

## Defines a variable that is to be used in a [JEP_EventGraph]

@export_storage var name : StringName
@export_storage var type : int

func _init(p_name := &"", p_type := TYPE_NIL) -> void:
	name = p_name
	type = p_type
