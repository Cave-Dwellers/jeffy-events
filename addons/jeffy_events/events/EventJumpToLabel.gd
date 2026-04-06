@tool
class_name EventJumpToLabel extends JEP_Event

@export_storage var label : String

func _event(ctx : Object = null) -> int:
	return 0

func _get_instructions() -> Dictionary:
	return {}

func _get_name() -> StringName:
	return &"Jump To Label"

func _get_description() -> StringName:
	return &"""Restarts graph execution at the provided label."""
