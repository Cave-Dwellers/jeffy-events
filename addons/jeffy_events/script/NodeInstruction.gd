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

## Returns the amount of input ports defined in this instruction
func get_input_port_count() -> int:
	var count : int = 0
	for element : JEP_ElementInstruction in elements:
		if element is not JEP_ElementInstruction.Port:
			continue
		element = element as JEP_ElementInstruction.Port
		count += int(element._has_in)
	return count

## Returns the amount of output ports defined in this instruction
func get_output_port_count() -> int:
	var count : int = 0
	for element : JEP_ElementInstruction in elements:
		if element is not JEP_ElementInstruction.Port:
			continue
		element = element as JEP_ElementInstruction.Port
		count += int(element._has_out)
	return count
