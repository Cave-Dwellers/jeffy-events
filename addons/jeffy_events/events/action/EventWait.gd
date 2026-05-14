@tool
class_name EventWait extends JEP_Event

@export_storage var time : float

func _event(ctx : JEP_GraphContext) -> int:
	await ctx.scene_tree.create_timer(time, false).timeout
	return 0

func _get_instruction(graph : JEP_EventGraph) -> JEP_NodeInstruction:
	return NODE.new(graph, self)\
			.with_element(ELEMENT.Port.new(&"Flow").with_input().with_output())\
			.with_element(ELEMENT.Number.new(&"time").with_step(0.1))

func _get_name() -> StringName:
	return &"Wait"

func _get_description() -> StringName:
	return &"Pauses execution for a given period of time"
