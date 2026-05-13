@tool
class_name JEP_EventGraphNode extends GraphNode

const THEME : Theme = preload("res://addons/jeffy_events/asset/theme.tres")

## Fired when the node is built
signal built(node : JEP_EventGraphNode)

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

var _event : JEP_Event
var _uuid : StringName

var connection_listeners : Array[JEP_NodeConnectionListener]

func _init(event : JEP_Event, graph : JEP_EventGraph) -> void:
	_event = event
	_uuid = graph.get_event_uuid(event)
	
	slot_sizes_changed.connect(reset_size)
	position_offset = event.position
	connection_listeners = []
	
	# Set titlebar color
	var script : GDScript = _event.get_script()
	var path : String = script.resource_path.get_base_dir() + "/"
	var color : Color = JEP_FolderColorAPI.get_color(path).darkened(0.2)
	
	if color != Color.WHITE:
		var titlebar : StyleBoxFlat = THEME.get_stylebox(&"titlebar", &"GraphNode").duplicate()
		var titlebar_selected : StyleBoxFlat = THEME.get_stylebox(&"titlebar_selected", &"GraphNode").duplicate()
		
		titlebar.bg_color = color
		titlebar_selected.bg_color = color
		
		add_theme_stylebox_override(&"titlebar", titlebar)
		add_theme_stylebox_override(&"titlebar_selected", titlebar_selected)
	
	parse_instruction(event, graph)

func parse_instruction(event : JEP_Event, graph : JEP_EventGraph) -> void:
	# Remove existing
	connection_listeners.clear()
	for child in get_children():
		if child is not Control:
			continue
		child.queue_free()
		await child.tree_exited
	
	var instruction := event._get_instruction(graph)
	if !instruction.is_static:
		
		graph.changed.connect(parse_instruction.bind(event, graph), CONNECT_ONE_SHOT)
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_node_instruction(instruction, self)
	
	for element_instruction : JEP_ElementInstruction in instruction.elements:
		parse_element_instruction(self, event, element_instruction)
	
	built.emit(self)

func parse_element_instruction(graph_node : GraphNode, event : JEP_Event, instruction : JEP_ElementInstruction) -> void:
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_element_instruction(instruction, event, graph_node)

## Adds an input connection listener to this [JEP_EventGraphNode]. The
## listener accepts an input node (which can be whatever you want) and
## a callable that will fire that must accept two arguments: an input
## reference [Control], and the state of the connection [bool]. 
## 
## This method can be used to update the state of a property's input field,
## usually when a data input port has been connected, as to prevent the
## user from setting otherwise redundant data in the field
func add_connection_listener(slot : int, input : Control, update : Callable) -> void:
	var listener : JEP_NodeConnectionListener = JEP_NodeConnectionListener.new()
	listener.input_ref = weakref(input)
	listener.slot = slot
	listener.on_update = update
	connection_listeners.append(listener)

func input_update(slot : int, connected : bool) -> void:
	# We want a duplicate so we can remove any invalid listeners
	# on the original array
	var listeners : Array = connection_listeners.duplicate()
	for listener : JEP_NodeConnectionListener in listeners:
		if listener.slot != slot:
			continue
		
		if !listener._on_update(connected):
			connection_listeners.erase(listener)

func get_event() -> JEP_Event:
	return _event

func get_uuid() -> StringName:
	return _uuid
