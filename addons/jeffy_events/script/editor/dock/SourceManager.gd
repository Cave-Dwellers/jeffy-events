@tool
class_name JEP_SourceManager extends Node

## Orchestrates source actions (adding, removal, reloading)

const FOLDER_COLORS : Dictionary[String, Color] = {
	"red" = Color(1.0, 0.271, 0.271),
	"orange" = Color(1.0, 0.561, 0.271),
	"yellow" = Color(1.0, 0.890, 0.271),
	"green" = Color(0.502, 1.0, 0.271),
	"teal" = Color(0.271, 1.0, 0.635),
	"blue" = Color(0.271, 0.843, 1.0),
	"purple" = Color(0.502, 0.271, 1.0),
	"pink" = Color(1.0, 0.271, 0.588),
	"gray" = Color(0.616, 0.616, 0.616),
}
const SOURCES : JEP_EventDatabase = preload("res://addons/jeffy_events/sources.tres")
const ICO_SOURCE : Texture2D = preload("res://addons/jeffy_events/asset/icon/Folder.svg")
const ICO_EVENT : Texture2D = preload("res://addons/jeffy_events/asset/icon/Object.svg")

## Emitted when directory parsing is requested
signal parse_requested(source : JEP_Source)

@export var add_source_modal : JEP_AddEventSourceModal
@export var remove_source_modal : JEP_ConfirmationModal

@export var source_tree : Tree
@export var no_sources_label : Label
@export var add_source_button : Button
@export var remove_source_button : Button
@export var refresh_sources_button : Button

var toaster : EditorToaster :
	get : return EditorInterface.get_editor_toaster()

func _on_dock_ready() -> void:
	# Disable buttons at start
	remove_source_button.disabled = true
	refresh_sources_button.disabled = true
	
	# Connect signals
	add_source_button.pressed.connect(_add_source_prompt.bind())
	remove_source_button.pressed.connect(_remove_source_prompt.bind())
	refresh_sources_button.pressed.connect(_refresh_sources.bind())
	add_source_modal.source_added.connect(_refresh_sources.bind())
	remove_source_modal.confirmed.connect(_remove_source_confirm.bind())
	source_tree.item_selected.connect(_entry_selected.bind())
	
	# Refresh
	_refresh_sources()

func _entry_selected() -> void:
	# Reset state
	remove_source_button.disabled = true
	
	# Get selected item
	var selected := source_tree.get_selected()
	if !selected:
		return
	
	# Determine what it is based on metadata
	var metadata = selected.get_metadata(0)
	if metadata is JEP_Source:
		# This is a source branch, allow removal
		remove_source_button.disabled = false
		return

func _add_source_prompt() -> void:
	# Show the modal to the user
	add_source_modal.show()

func _remove_source_prompt() -> void:
	# Show the modal to the user
	remove_source_modal.show()

func _remove_source_confirm() -> void:
	# Get selected
	var selected := source_tree.get_selected()
	if !selected:
		return
	
	# Determine what it is based on metadata
	var metadata = selected.get_metadata(0)
	if metadata is JEP_Source:
		SOURCES.remove_source(metadata)
		_refresh_sources()
		return
	
	# Otherwise, what were we trying to remove?
	push_error("Tried to remove event source that doesnt exist")

func _refresh_sources() -> void:
	# Reset tree and recreate root
	source_tree.clear()
	source_tree.create_item().set_text(0, "root")
	
	# Get folder colors
	JEP_FolderColorAPI.rebuild_cache()
	
	# Show "No sources!" if we have none tracked
	if !SOURCES.has_sources():
		no_sources_label.visible = true
		refresh_sources_button.disabled = true
		return
	
	# Allow manual refresh and hide label since we have sources to work with
	no_sources_label.visible = false
	refresh_sources_button.disabled = false
	
	# Validate before parsing
	SOURCES.validate()
	
	# Iterate and parse
	for source in SOURCES.sources:
		parse_requested.emit(source)
	
	# Tell user the result
	toaster.push_toast("%d event source%s refreshed." % [SOURCES.sources.size(), "s" if SOURCES.sources.size() > 1 else ""])

func _build_menu_from_source(result : Dictionary, source : JEP_Source) -> void:
	var parent := source_tree.create_item()
	parent.set_text(0, "%s (%s)" % [source.name, source.location])
	parent.set_icon(0, ICO_SOURCE)
	parent.set_metadata(0, source)
	
	_build_branch_from_dict(result, parent)

func _build_branch_from_dict(dict : Dictionary, parent : TreeItem, color : Color = Color.WHITE) -> void:
	for file_name : String in dict.keys():
		# Skip "private" entries
		if file_name.begins_with("__"):
			continue
		
		var value = dict[file_name]
		var entry := parent.create_child()
		
		# If dictionary value, build another branch
		if value is Dictionary:
			var folder_color = value.get("__COLOR", Color.WHITE)
			var folder_color_bg : Color = Color(folder_color, 0.05)
			
			entry.set_text(0, file_name.capitalize())
			entry.set_icon(0, ICO_SOURCE)
			entry.set_icon_modulate(0, folder_color)
			entry.set_custom_color(0, folder_color)
			entry.set_custom_bg_color(0, folder_color_bg)
			_build_branch_from_dict(value, entry, folder_color)
			
			# Cut this iteration off early
			continue
		
		# Otherwise, it is a context object
		value = value as JEP_DirectoryParser.EventInfo
		entry.set_text(0, value.name)
		entry.set_tooltip_text(0, value.desc)
		entry.set_metadata(0, value.event_script)
		entry.set_icon(0, ICO_EVENT)
		entry.set_icon_modulate(0, color)
		
