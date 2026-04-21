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

var graph : JEP_EventGraph
var selected : Array[JEP_EventGraphNode] :
	get :
		var sel : Array[JEP_EventGraphNode] = []
		for child in get_children():
			if child is not JEP_EventGraphNode:
				continue
			
			child = child as JEP_EventGraphNode
			if child.selected:
				sel.append(child)
		return sel

func on_graph_parsed(p_graph : JEP_EventGraph, nodes : Array[GraphNode]) -> void:
	graph = p_graph
	
	for child : Node in get_children():
		if child is GraphNode:
			child.queue_free()
	
	for node : GraphNode in nodes:
		add_child(node)
		
	# Handle connections
	for connection : JEP_EventGraphConnection in p_graph._connections:
		connect_node(str(connection.from_event), connection.from_port, str(connection.to_event), connection.to_port)

func _on_connection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	var from_node := get_node(NodePath(from_path)) as GraphNode
	var from_port_type := from_node.get_output_port_type(from_port)
	var connection_type := JEP_EventGraphConnection.Type.Flow if from_port_type == 0 else JEP_EventGraphConnection.Type.Data
	
	connect_node(from_path, from_port, to_path, to_port)
	graph.add_connection(int(from_path), from_port, int(to_path), to_port, connection_type)
	
func _on_disconnection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	disconnect_node(from_path, from_port, to_path, to_port)
	graph.remove_connection(int(from_path), from_port, int(to_path), to_port)

func _on_nodes_moved() -> void:
	for node : JEP_EventGraphNode in selected:
		node.event.position = node.position_offset

func _on_copy_nodes() -> void:
	pass

func _on_cut_nodes() -> void:
	pass

func _on_duplicate_nodes() -> void:
	pass

func _on_paste_nodes() -> void:
	pass
