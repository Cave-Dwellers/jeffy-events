@tool
class_name EventTerminator extends JEP_Event

func _event(ctx : Object = null) -> int:
	return 0

func _get_instructions() -> Dictionary:
	return {}

func _get_name() -> StringName:
	return &"Terminator"

func _get_description() -> StringName:
	return &"""An end point for an EventGraph."""
