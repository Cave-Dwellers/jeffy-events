@tool
class_name EventComment extends JEP_Event

func _event(ctx : Object = null) -> int:
	return 0

func _get_instructions() -> Dictionary:
	return {}

func _get_name() -> StringName:
	return &"Comment"

func _get_description() -> StringName:
	return &"""A comment block for documentation"""
