@tool
class_name JEP_AddEventSourceModal extends JEP_Modal

## Fired when source has been successfully added.
signal source_added()

const SOURCES : JEP_EventDatabase = preload("res://addons/jeffy_events/sources.tres")

@onready var name_field : LineEdit = $Panel/Margin/Sort/Name/NameLine
@onready var path_field : LineEdit = $Panel/Margin/Sort/Path/PathLine
@onready var path_button : Button = $Panel/Margin/Sort/Path/LoadButton
@onready var add_button : Button = $Panel/Margin/Sort/Buttons/Add
@onready var cancel_button : Button = $Panel/Margin/Sort/Buttons/Cancel

## The name the user has supplied
var s_name : String :
	get : return name_field.text
	set(value) : name_field.text = value
## The path the user has supplied
var s_path : String :
	get : return path_field.text
	set(value) : path_field.text = value

func _ready() -> void:
	super._ready()
	
	# Disable button
	add_button.disabled = true
	
	# Connect signals
	path_button.pressed.connect(_open_dir_picker.bind())
	add_button.pressed.connect(_add_source.bind())
	cancel_button.pressed.connect(close.bind())

func _reset_state() -> void:
	add_button.disabled = true
	s_name = ""
	s_path = ""

func _open_dir_picker() -> void:
	# Create file picker object
	var picker := EditorFileDialog.new()
	picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	picker.display_mode = FileDialog.DISPLAY_LIST
	
	# Connect signal and show to user
	picker.dir_selected.connect(_dir_selected.bind())
	add_child(picker)
	picker.popup_centered_clamped()

func _dir_selected(dir : String) -> void:
	# Set path to dir
	s_path = dir
	if s_name.is_empty():
		s_name = s_path.simplify_path()
	
	# Enable button if the path is valid
	if _should_enable_button():
		add_button.disabled = false
	else:
		add_button.disabled = true

func _add_source() -> void:
	SOURCES.add_source(s_path, s_name)
	source_added.emit()
	close()

func _should_enable_button() -> bool:
	# TODO: More nuanced checking against EventSources
	return !s_path.is_empty()
