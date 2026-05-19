@tool
class_name JEP_EventGraphNode extends GraphNode

const THEME : Theme = preload("res://addons/jeffy_events/asset/theme.tres")
const TITLEBAR_BUTTON_MARIGN : int = 20

## Fired when the node is built
signal built(node : JEP_EventGraphNode)
## Fired when event removal is requested
signal remove_requested(node : JEP_EventGraphNode)

## TODO: registry system for this shit
var _HANDLERS = [JEP_BuiltinInstructionHandler.new()]

var _is_building : bool = false
var _event : JEP_Event
var _uuid : StringName

var connection_listeners : Array[JEP_NodeConnectionListener]

func _init(event : JEP_Event, graph : JEP_EventGraph) -> void:
	_event = event
	_uuid = event.uuid
	
	slot_sizes_changed.connect(reset_size)
	position_offset = event.position
	connection_listeners = []
	
	# Set titlebar color
	var script : GDScript = _event.get_script()
	var path : String = script.resource_path.get_base_dir() + "/"
	var color : Color = JEP_FolderColorAPI.get_color(path).darkened(0.2)
	
	if color != Color.WHITE:
		var t_titlebar : StyleBoxFlat = THEME.get_stylebox(&"titlebar", &"GraphNode").duplicate()
		var t_titlebar_selected : StyleBoxFlat = THEME.get_stylebox(&"titlebar_selected", &"GraphNode").duplicate()
		
		t_titlebar.bg_color = color
		t_titlebar_selected.bg_color = color
		
		add_theme_stylebox_override(&"titlebar", t_titlebar)
		add_theme_stylebox_override(&"titlebar_selected", t_titlebar_selected)
	
	parse_instruction(event, graph)

func _ready() -> void:
	# Add delete button
	var titlebar : HBoxContainer = get_titlebar_hbox()
	titlebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var delete : Button = Button.new()
	delete.theme_type_variation = &"ButtonTitlebar"
	delete.icon = preload("res://addons/jeffy_events/asset/icon/Remove.svg")
	delete.pressed.connect(remove_requested.emit.bind(self))
	delete.size_flags_horizontal = Control.SIZE_SHRINK_END
	titlebar.add_child(delete)
	
	var target_size : Vector2 = titlebar.get_parent_control().get_minimum_size()
	titlebar.custom_minimum_size.x = target_size.x - TITLEBAR_BUTTON_MARIGN
	
	# Jeff - Sometimes sorting is a little messed up on graph nodes,
	# so this waits for a draw frame before calling for a sort of our elements
	await get_tree().process_frame
	queue_sort.call_deferred()

func parse_instruction(event : JEP_Event, graph : JEP_EventGraph) -> void:
	# Dont let this be called several times in a frame
	if _is_building:
		return
	_is_building = true
	
	# Remove existing
	connection_listeners.clear()
	for child in get_children():
		if child is not Control:
			continue
		child.queue_free()
		await child.tree_exited
	
	var instruction := event._get_instruction(graph)
	if !instruction.is_static:
		event.changed.connect(parse_instruction.bind(event, graph), CONNECT_ONE_SHOT)
		event.changed.connect(queue_sort, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	
	for handler : JEP_InstructionHandler in _HANDLERS:
		handler._handle_node_instruction(instruction, self)
	
	for element_instruction : JEP_ElementInstruction in instruction.elements:
		parse_element_instruction(self, event, element_instruction)
	
	built.emit(self)
	_is_building = false

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
