@tool
class_name JEP_EnumLineField extends JEP_AbstractEnumField

func _selected_wrapper(idx : int) -> void:
	field = field as OptionButton
	_set_value(field.get_item_text(idx))

func _on_value_changed() -> void:
	var value : String = event.get(property)
	
	for i : int in range(field.item_count):
		if field.get_item_text(i) == value:
			field.selected = i
			break
