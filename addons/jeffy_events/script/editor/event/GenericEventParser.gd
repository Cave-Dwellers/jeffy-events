@tool
class_name JEP_GenericEventParser extends JEP_AbstractEventParser

func _handle_entry(_type : String, data : Dictionary) -> void:
	var d_property_name := data["property"] as StringName
	var d_
