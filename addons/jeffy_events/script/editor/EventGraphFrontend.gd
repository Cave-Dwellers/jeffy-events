@tool
class_name JEP_EventGraphFrontend extends GraphEdit

## Displays a mutable representation of [JEP_EventGraph] data.
##
## The general design of this script is to hook the [JEP_EventGraph]
## resource signals. Frontend updates are based on whether or not
## changes go through on the resource itself

signal graph_refresh_requested(graph : JEP_EventGraph)

const Ports := JEP_PortInfo.Ports

@export var graph_parser : JEP_GraphParser
@export var no_graph_label : Label

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

func _dock_ready() -> void:
	# Add port types
	var type_indice : int = 0
	for type_name : String in JEP_PortInfo.Ports.keys():
		type_names[type_indice] = type_name
		type_indice += 1
	
	# Add connection support for variant
	add_valid_connection_type(Ports.DataNumber, Ports.DataVariant)
	add_valid_connection_type(Ports.DataString, Ports.DataVariant)
	add_valid_connection_type(Ports.DataBool, Ports.DataVariant)
	add_valid_connection_type(Ports.DataNodePath, Ports.DataVariant)
	add_valid_connection_type(Ports.DataResource, Ports.DataVariant)

	var reload : Button = Button.new()
	reload.name = "ReloadButton"
	reload.icon = preload("uid://bmaqov8dsbe5f")
	reload.pressed.connect(_refresh_graph.bind())
	reload.tooltip_text = &"Reloads the currently focused event graph."
	get_menu_hbox().add_child(reload)

func _on_graph_selected(p_graph : JEP_EventGraph) -> void:
	# Remove old signals
	if is_instance_valid(graph):
		graph.event_added.disconnect(_on_event_added)
		graph.event_removed.disconnect(_on_event_removed)
		graph.connection_added.disconnect(_on_connection_added)
		graph.connection_removed.disconnect(_on_connection_removed)
	
	# Add new signals
	graph = p_graph
	if is_instance_valid(graph):
		graph.event_added.connect(_on_event_added)
		graph.event_removed.connect(_on_event_removed)
		graph.connection_added.connect(_on_connection_added)
		graph.connection_removed.connect(_on_connection_removed)
	
	# Refresh graph
	_refresh_graph()

func on_graph_parsed(p_graph : JEP_EventGraph, nodes : Array[GraphNode]) -> void:
	# Ensure we're cleared
	await _clear()
	
	# Add new nodes
	for node : JEP_EventGraphNode in nodes:
		_add_graph_node(node)
		
	# Handle connections
	for uuid : StringName in p_graph._connections.keys():
		var array := p_graph._connections[uuid]
		for connection : JEP_EventGraphConnection in array:
			connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
			_signal_node_connection(connection, true)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if !visible:
				return
			
			for node in get_children():
				if node is not JEP_EventGraphNode:
					continue
				
				# Nodes need to be sorted
				node = node as JEP_EventGraphNode
				node.get_titlebar_hbox().queue_sort()
				node.queue_sort()

func _clear() -> void:
	uuid_to_node.clear()
	for child : Node in get_children():
		if child is GraphNode:
			child.queue_free()
			await child.tree_exited

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

func _graph_node_rebuilt(node : JEP_EventGraphNode) -> void:
	# Wait for node to be populated
	var connections_to := graph.get_connections_to(node._uuid)
	var connections_broken : int = 0
	
	var instruction : JEP_NodeInstruction = node._event._get_instruction(graph)
	for connection : JEP_EventGraphConnection in connections_to:
		# If port count changed, and we're past it, remove
		if instruction.get_input_port_count() <= connection.to_port:
			if graph.remove_connection_object(connection):
				connections_broken += 1
			continue
		
		var from_node : JEP_EventGraphNode = get_node(NodePath(connection.from_uuid))
		var from_type : int = from_node.get_output_port_type(connection.from_port)
		var to_type : int = node.get_input_port_type(connection.to_port)
		
		# If types changed, remove
		if from_type != to_type:
			if graph.remove_connection_object(connection):
				connections_broken += 1
			continue
	
	if connections_broken > 0:
		JEP_Print.toast_warn("%d event connection%s broken" % [connections_broken, "s were" if connections_broken > 1 else " was"])

func _graph_node_removed(node : JEP_EventGraphNode) -> void:
	graph.remove_event(node._event)

func _add_graph_node(node : JEP_EventGraphNode) -> void:
	add_child(node)
	uuid_to_node[node._uuid] = node
	node.built.connect(_graph_node_rebuilt.bind(), CONNECT_DEFERRED)
	node.remove_requested.connect(_graph_node_removed.bind(), CONNECT_DEFERRED)
	node.queue_sort.call_deferred()

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
	_add_graph_node(node)

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
	to_node.input_update(to_slot, connected)

func _refresh_graph() -> void:
	await _clear()
	
	if !is_instance_valid(graph):
		no_graph_label.show()
		hide()
		return
	
	no_graph_label.hide()
	show()
	graph_refresh_requested.emit(graph)

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
