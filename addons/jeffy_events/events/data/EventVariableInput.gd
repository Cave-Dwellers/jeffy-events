@tool
class_name EventVariableInput extends JEP_Event

func _event(ctx : JEP_GraphContext) -> int:
	return 0

func _get_name() -> StringName:
	return &"Variable Input"

func _get_description() -> StringName:
	return &"An interface for variables defined in the graph"

func is_data() -> bool:
	return true

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	var ins := NODE.new(graph, self).dynamic()
	
	if graph._variables.is_empty():
		ins.with_element(ELEMENT.new().with_label("No variables defined"))
		return ins
	
	for v : JEP_EventGraphVariable in graph._variables:
		var port_type : int = JEP_PortInfo.TypeToPort[v.type]
		ins.with_element(ELEMENT.DataSource.new(v.name).without_input().with_type(port_type).with_output())
	
	return ins

func _pull_data(port : int, ctx : JEP_GraphContext) -> Variant:
	var graph : JEP_EventGraph = ctx.graph
	var variable : JEP_EventGraphVariable = graph._variables[port]
	
	return ctx.graph_player._variables.get(variable.name)
