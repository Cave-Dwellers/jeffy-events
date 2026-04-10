@tool
class_name JEP_FilePicker extends HBoxContainer

## Handles file picking from user system

@export var file_mode : FileDialog.FileMode
@export var display_mode : FileDialog.DisplayMode
@export var filter : StringName = &""
@export var filter_desc : StringName = &""

signal picked_path(path : String)
signal picked_paths(paths : PackedStringArray)

@onready var button : Button = $Load

func _ready() -> void:
	# Connect signals
	button.pressed.connect(popup)
	
func popup() -> void:
	# Create file picker object
	var picker := EditorFileDialog.new()
	picker.file_mode = file_mode
	picker.display_mode = display_mode
	
	if !filter.is_empty():
		picker.add_filter(filter, filter_desc)
		
	# Disable button, we dont want the user to
	# have several file picker menus at once
	button.disabled = true
	picker.canceled.connect(button.set.bind(&"disabled", false))
	
	# Connect signal and show to user
	match file_mode:
		FileDialog.FILE_MODE_OPEN_DIR: picker.dir_selected.connect(_path_selected.bind())
		FileDialog.FILE_MODE_OPEN_FILE: picker.file_selected.connect(_path_selected.bind())
		FileDialog.FILE_MODE_SAVE_FILE: picker.file_selected.connect(_path_selected.bind())
		FileDialog.FILE_MODE_OPEN_FILES: picker.files_selected.connect(_paths_selected.bind())
	
	add_child(picker)
	picker.popup_centered_clamped()

func _path_selected(path : String) -> void:
	picked_path.emit(path)
	button.disabled = false

func _paths_selected(paths : PackedStringArray) -> void:
	picked_paths.emit(paths)
	button.disabled = false
