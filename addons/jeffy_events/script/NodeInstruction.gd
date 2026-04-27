@tool
class_name JEP_NodeInstruction extends RefCounted

var graph : JEP_EventGraph
var event : JEP_Event
var elements : Array[JEP_ElementInstruction] = []

## Whether or not the event node will regenerate itself
## when a property is changed
var is_static : bool = true

func _init(p_graph : JEP_EventGraph, p_event : JEP_Event) -> void:
	graph = p_graph
	event = p_event

func dynamic() -> JEP_NodeInstruction:
	is_static = false
	return self

func with_element(instruction : JEP_ElementInstruction) -> JEP_NodeInstruction:
	elements.append(instruction)
	return self
