@tool
class_name JEP_NodeInstruction extends RefCounted

var event : JEP_Event
var elements : Array[JEP_ElementInstruction] = []
## Whether or not the event node will regenerate itself
## when a property is changed
var is_static : bool = true

func _init(p_event : JEP_Event) -> void:
	event = p_event

func dynamic() -> JEP_NodeInstruction:
	is_static = false
	return self

func with_element(instruction : JEP_ElementInstruction) -> JEP_NodeInstruction:
	elements.append(instruction)
	return self
