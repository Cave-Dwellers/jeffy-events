@tool
class_name JEP_EventGraphFrontend extends GraphEdit

## Displays a mutable representation of [JEP_EventGraph] data.
##
## The general design of this script is to hook the [JEP_EventGraph]
## resource signals. Frontend updates are based on whether or not
## changes go through on the resource itself

signal graph_refresh_requested(graph : JEP_EventGraph)

const PORTS := JEP_PortInfo.Ports

@export var graph_undo_redo : JEP_GraphUndoRedo
@export var graph_parser : JEP_GraphParser
@export var no_graph_label : Label

## The [JEP_EventGraph] we're editing currently
var graph : JEP_EventGraph
## Map of event uuid -> [JEP_EventGraphNode]
var uuid_to_node : Dictionary[StringName, JEP_EventGraphNode] = {}
## Current graph node selection
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

## Current [UndoRedo] for graph
var undo_redo : UndoRedo :
	get : return graph_undo_redo.get_undo_redo(graph)

func _dock_ready() -> void:
	# Add port types
	var type_indice : int = 0
	for type_name : String in PORTS.keys():
		type_names[type_indice] = type_name
		type_indice += 1
	
	# Add connection support for variant
	add_valid_connection_type(PORTS.DataNumber, PORTS.DataVariant)
	add_valid_connection_type(PORTS.DataString, PORTS.DataVariant)
	add_valid_connection_type(PORTS.DataBool, PORTS.DataVariant)
	add_valid_connection_type(PORTS.DataNodePath, PORTS.DataVariant)
	add_valid_connection_type(PORTS.DataResource, PORTS.DataVariant)

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
				node.queue_sort()

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey || !is_visible_in_tree() || !graph:
		return
	event = event as InputEventKey
	
	if event.is_pressed() && event.is_command_or_control_pressed():
		if event.shift_pressed && event.keycode == KEY_Z:
			graph_undo_redo.redo(graph)
			return
		
		match event.keycode:
			KEY_Z:	graph_undo_redo.undo(graph); return
			KEY_Y:	graph_undo_redo.redo(graph); return

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
	print(connections_to)
	var connections_broken : int = 0
	
	var instruction : JEP_NodeInstruction = node._event._get_instruction(graph)
	for connection : JEP_EventGraphConnection in connections_to:
		print("Connections Son")
		# If port count changed, and we're past it, remove
		if instruction.get_input_port_count() <= connection.to_port:
			print("Ports too large")
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
	undo_redo.create_action("Removed event")
	undo_redo.add_do_method(graph.remove_event.bind(node.get_event()))
	undo_redo.add_undo_method(graph.add_event.bind(node.get_event(), node.get_event().position))
	undo_redo.add_undo_method(graph.add_connection_objects.bind(graph.get_connections(node.get_uuid())))
	undo_redo.commit_action()

func _add_graph_node(node : JEP_EventGraphNode) -> void:
	add_child(node)
	uuid_to_node[node._uuid] = node
	node.built.connect(_graph_node_rebuilt.bind(), CONNECT_DEFERRED)
	node.remove_requested.connect(_graph_node_removed.bind(), CONNECT_DEFERRED)

func _on_connection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	var from_node := get_node(NodePath(from_path)) as GraphNode
	var from_port_type := from_node.get_output_port_type(from_port)
	var connection_type := JEP_EventGraphConnection.Type.Flow if from_port_type == 0 else JEP_EventGraphConnection.Type.Data
	
	undo_redo.create_action("Connection formed")
	undo_redo.add_do_method(graph.add_connection.bind(from_path, from_port, to_path, to_port, connection_type))
	undo_redo.add_undo_method(graph.remove_connection.bind(from_path, from_port, to_path, to_port))
	undo_redo.commit_action()
	
func _on_disconnection_request(from_path : StringName, from_port : int, to_path : StringName, to_port : int) -> void:
	var from_node := get_node(NodePath(from_path)) as GraphNode
	var from_port_type := from_node.get_output_port_type(from_port)
	var connection_type := JEP_EventGraphConnection.Type.Flow if from_port_type == 0 else JEP_EventGraphConnection.Type.Data
	
	undo_redo.create_action("Connection removed")
	undo_redo.add_do_method(graph.remove_connection.bind(from_path, from_port, to_path, to_port))
	undo_redo.add_undo_method(graph.add_connection.bind(from_path, from_port, to_path, to_port, connection_type))
	undo_redo.commit_action()

func _on_remove_request(nodes : Array[StringName]) -> void:
	for uuid : StringName in nodes:
		var node : JEP_EventGraphNode = uuid_to_node[uuid]
		var event : JEP_Event = node.get_event()
		
		undo_redo.create_action("Event(s) removed", UndoRedo.MERGE_ALL)
		undo_redo.add_do_method(graph.remove_event.bind(event))
		undo_redo.add_undo_method(graph.add_event.bind(event, event.position))
		undo_redo.commit_action()

func _on_event_added(event : JEP_Event, uuid : StringName) -> void:
	#JEP_Print.info("Event added: uuid %s" % uuid)
	var node : JEP_EventGraphNode = JEP_EventGraphNode.new(event, graph)
	
	_add_graph_node(node)

func _on_event_removed(_event : JEP_Event, uuid : StringName) -> void:
	#JEP_Print.info("Event removed: uuid %s" % uuid)
	var node : JEP_EventGraphNode = uuid_to_node[uuid]
	
	uuid_to_node.erase(uuid)
	node.queue_free()

func _on_connection_added(connection : JEP_EventGraphConnection) -> void:
	connect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	queue_redraw()
	
	_signal_node_connection(connection, true)

func _on_connection_removed(connection : JEP_EventGraphConnection) -> void:
	disconnect_node(connection.from_uuid, connection.from_port, connection.to_uuid, connection.to_port)
	queue_redraw()
	
	_signal_node_connection(connection, false)

func _on_nodes_moved() -> void:
	for node : JEP_EventGraphNode in selected:
		undo_redo.create_action("Event(s) moved", UndoRedo.MERGE_ALL)
		undo_redo.add_do_property(node.get_event(), &"position", node.position_offset)
		undo_redo.add_do_property(node, &"position_offset", node.position_offset)
		undo_redo.add_undo_property(node.get_event(), &"position", node.get_event().position)
		undo_redo.add_undo_property(node, &"position_offset", node.get_event().position)
		undo_redo.commit_action()
		
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
	
	undo_redo.create_action("Added event %s" % data._get_name())
	undo_redo.add_do_method(graph.add_event.bind(data, (at_position + scroll_offset) / zoom))
	undo_redo.add_undo_method(graph.remove_event.bind(data))
	undo_redo.commit_action()

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
