@tool
class_name EventLabel extends JEP_Event

@export_storage var label : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instructions() -> Dictionary:
	return {}

func _get_name() -> StringName:
	return &"Label"

func _get_description() -> StringName:
	return &"""A starting point for an EventGraph."""
