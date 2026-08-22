@tool
class_name JEP_EnumIntField extends JEP_AbstractEnumField

func _on_value_changed() -> void:
	var value : int = event.get(property)
	field.selected = value
