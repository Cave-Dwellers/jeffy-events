@tool
class_name JEP_EventGraphFrontend extends GraphEdit

enum Ports {
	Flow,
	DataVariant,
	DataNumber,
	DataString,
	DataBool,
	DataNodePath,
	DataResource
}

const PortColors : Dictionary[int, Color] = {
	Ports.Flow : Color.WHITE,
	Ports.DataVariant : Color.LAWN_GREEN,
	Ports.DataNumber : Color.SKY_BLUE,
	Ports.DataString : Color.GOLD,
	Ports.DataBool : Color.DARK_RED,
	Ports.DataNodePath : Color.OLIVE,
	Ports.DataResource : Color.MEDIUM_PURPLE
}

func on_graph_parsed(nodes : Array[GraphNode]) -> void:
	for child : Node in get_children():
		if child is GraphNode:
			child.queue_free()
	
	for node : GraphNode in nodes:
		add_child(node)
		
	# Handle connections
