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

@export var graph_parser : JEP_GraphParser

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
	if graph:
		graph.event_added.disconnect(_on_event_added)
		graph.connection_added.disconnect(_on_connection_added)
		graph.connection_removed.disconnect(_on_connection_removed)
	
	graph = p_graph
	graph.event_added.connect(_on_event_added)
	graph.connection_added.connect(_on_connection_added)
	graph.connection_removed.connect(_on_connection_removed)
	
	for child : Node in get_children():
		if child is GraphNode:
			child.queue_free()
	
	for node : GraphNode in nodes:
		add_child(node)
		
	# Handle connections
	for uuid : StringName in p_graph._connections.keys():
		var array := p_graph._connections[uuid]
		for connection : JEP_EventGraphConnection in array:
			connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)

func _on_connection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	var from_node := get_node(NodePath(from_path)) as GraphNode
	var from_port_type := from_node.get_output_port_type(from_port)
	var connection_type := JEP_EventGraphConnection.Type.Flow if from_port_type == 0 else JEP_EventGraphConnection.Type.Data
	
	graph.add_connection(from_path, from_port, to_path, to_port, connection_type)
	
func _on_disconnection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	graph.remove_connection(from_path, from_port, to_path, to_port)

func _on_event_added(event : JEP_Event, uuid : StringName) -> void:
	JEP_Print.info("Event added: uuid %s" % uuid)
	var instruction : JEP_NodeInstruction = event._get_instruction(graph)
	var node : JEP_EventGraphNode = graph_parser.parse_instruction(instruction, graph)
	
	node.name = uuid
	add_child(node)

func _on_connection_added(connection : JEP_EventGraphConnection) -> void:
	connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	JEP_Print.info("Connection made: %s...@%d -> %s...@%d" % [connection.from_uuid.substr(0, 8), connection.from_port, connection.to_uuid.substr(0, 8), connection.to_port])

func _on_connection_removed(connection : JEP_EventGraphConnection) -> void:
	disconnect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	JEP_Print.info("Connection broken: %s...@%d -> %s...@%d" % [connection.from_uuid.substr(0, 8), connection.from_port, connection.to_uuid.substr(0, 8), connection.to_port])

func _on_nodes_moved() -> void:
	for node : JEP_EventGraphNode in selected:
		node.get_event().position = node.position_offset

#region Drag And Drop

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is JEP_Event

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data = data as JEP_Event
	graph.add_event(data, (at_position + scroll_offset) / zoom)

#endregion
#region Clipboard

func _on_copy_nodes() -> void:
	pass

func _on_cut_nodes() -> void:
	pass

func _on_duplicate_nodes() -> void:
	pass

func _on_paste_nodes() -> void:
	pass

#endregion
