@tool
class_name EventRemoveNode extends JEP_Event

@export_storage var node_path : NodePath

func _event(ctx : JEP_GraphContext) -> int:
	var node : Node = ctx.get_node_or_null(node_path)
	if node: node.queue_free()
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
				.with_element(ELEMENT.Port.new(&"Flow").with_input().with_output())\
				.with_element(ELEMENT.NodePathField.new(&"node_path"))

func _get_name() -> StringName:
	return &"Remove Node"

func _get_description() -> StringName:
	return &"Removes a node from the SceneTree using queue free"
