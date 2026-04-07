@tool
class_name JEP_LabelsListManager extends JEP_AbstractListManager

@export var line_edit : LineEdit 

func _configure_new_entry(instance : Control) -> void:
	var i_line := instance.get_node("Label") as LineEdit
	var i_button := instance.get_node("Button") as Button
	
	i_line.text = line_edit.text
	i_button.pressed.connect(_on_remove.bind())
	
	# Reset line edit
	line_edit.text = ""

func _on_remove(instance : Control) -> void:
	pass
