@tool
class_name JEP_NewEventGraphModal extends JEP_Modal

## Creates a [class JEP_EventGraph]

const TEXT_NEW : StringName = &"Create"
const TEXT_OVERRIDE : StringName = &"Override"
const VARIANT_CRITICAL : StringName = &"CriticalButton"

signal graph_created(graph : JEP_EventGraph)

# TODO: Preset options
@onready var file_path : LineEdit = $Panel/Margin/Sort/Path/FilePicker/Path
@onready var add_button : Button = $Panel/Margin/Sort/Buttons/Add
@onready var cancel_button : Button = $Panel/Margin/Sort/Buttons/Cancel

var s_path : String :
	get : return file_path.text
	set(value) : file_path.text = value

func _ready() -> void:
	super._ready()
	
	# Disable button
	add_button.disabled = true
	
	# Connect signals
	add_button.pressed.connect(_add_event)
	cancel_button.pressed.connect(close)

func _assign_path(path : String) -> void:
	s_path = path
	add_button.disabled = s_path.is_empty()
	
	if FileAccess.file_exists(path):
		add_button.text = TEXT_OVERRIDE
		add_button.theme_type_variation = VARIANT_CRITICAL
	else:
		add_button.text = TEXT_NEW
		add_button.theme_type_variation = &""

func _add_event() -> void:
	var graph := JEP_EventGraphFactory.create_default_at_path(s_path)
	graph_created.emit(graph)
	close()

func _reset_state() -> void:
	add_button.disabled = true
	s_path = ""
	
	add_button.text = TEXT_NEW
	add_button.theme_type_variation = &""
