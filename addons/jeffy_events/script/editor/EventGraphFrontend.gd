@tool
class_name JEP_EventGraphFrontend extends GraphEdit

## Displays a mutable representation of [JEP_EventGraph] data.
##
## The general design of this script is to hook the [JEP_EventGraph]
## resource signals. Frontend updates are based on whether or not
## changes go through on the resource itself

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
var uuid_to_node : Dictionary[StringName, JEP_EventGraphNode] = {}
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
	# Signal connections
	if graph:
		graph.event_added.disconnect(_on_event_added)
		graph.event_removed.disconnect(_on_event_removed)
		graph.connection_added.disconnect(_on_connection_added)
		graph.connection_removed.disconnect(_on_connection_removed)
	
	graph = p_graph
	graph.event_added.connect(_on_event_added)
	graph.event_removed.connect(_on_event_removed)
	graph.connection_added.connect(_on_connection_added)
	graph.connection_removed.connect(_on_connection_removed)
	
	# Remove old nodes
	uuid_to_node.clear()
	for child : Node in get_children():
		if child is GraphNode:
			child.queue_free()
			await child.tree_exited
	
	# Add new nodes
	for node : JEP_EventGraphNode in nodes:
		add_child(node)
		uuid_to_node[node._uuid] = node
		
	# Handle connections
	for uuid : StringName in p_graph._connections.keys():
		var array := p_graph._connections[uuid]
		for connection : JEP_EventGraphConnection in array:
			connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
			_signal_node_connection(connection, true)

func _draw() -> void:
	if !graph:
		return
	
	var font := get_theme_default_font()
	var x := size.x - 256
	var y := 16
	
	for uuid : StringName in graph._connections.keys():
		draw_string(font, Vector2(x, y), uuid, 0, -1, 12)
		y += 16
		
		var uuid_connections : Array = graph._connections[uuid]
		for connection : JEP_EventGraphConnection in uuid_connections:
			draw_string(font, Vector2(x + 32, y), "%d: %s...@%d" % [connection.from_port, connection.to_uuid.substr(0, 8), connection.to_port], 0, -1, 12)
			y += 16 

func _on_connection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	var from_node := get_node(NodePath(from_path)) as GraphNode
	var from_port_type := from_node.get_output_port_type(from_port)
	var connection_type := JEP_EventGraphConnection.Type.Flow if from_port_type == 0 else JEP_EventGraphConnection.Type.Data
	
	graph.add_connection(from_path, from_port, to_path, to_port, connection_type)
	
func _on_disconnection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	graph.remove_connection(from_path, from_port, to_path, to_port)

func _on_remove_request(nodes : Array[StringName]) -> void:
	for uuid : StringName in nodes:
		var node : JEP_EventGraphNode = uuid_to_node[uuid]
		var event : JEP_Event = node.get_event()
		graph.remove_event(event)

func _on_event_added(event : JEP_Event, uuid : StringName) -> void:
	JEP_Print.info("Event added: uuid %s" % uuid)
	var node : JEP_EventGraphNode = JEP_EventGraphNode.new(event, graph)
	
	node.name = uuid
	uuid_to_node[uuid] = node
	add_child(node)

func _on_event_removed(_event : JEP_Event, uuid : StringName) -> void:
	JEP_Print.info("Event removed: uuid %s" % uuid)
	var node : JEP_EventGraphNode = uuid_to_node[uuid]
	
	uuid_to_node.erase(uuid)
	node.queue_free()

func _on_connection_added(connection : JEP_EventGraphConnection) -> void:
	connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	queue_redraw()
	
	_signal_node_connection(connection, true)
	
	JEP_Print.info("Connection made: %s...@%d -> %s...@%d" % [connection.from_uuid.substr(0, 8), connection.from_port, connection.to_uuid.substr(0, 8), connection.to_port])

func _on_connection_removed(connection : JEP_EventGraphConnection) -> void:
	disconnect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	queue_redraw()
	
	_signal_node_connection(connection, false)
	
	JEP_Print.info("Connection broken: %s...@%d x %s...@%d" % [connection.from_uuid.substr(0, 8), connection.from_port, connection.to_uuid.substr(0, 8), connection.to_port])

func _on_nodes_moved() -> void:
	for node : JEP_EventGraphNode in selected:
		node.get_event().position = node.position_offset

func _signal_node_connection(connection : JEP_EventGraphConnection, connected : bool) -> void:
	var to_node : JEP_EventGraphNode = get_node(NodePath(connection.to_uuid))
	var to_slot : int = to_node.get_input_port_slot(connection.to_port)
	to_node.slot_connection_updated.emit(to_slot, connected)


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
