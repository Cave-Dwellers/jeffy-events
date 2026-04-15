@tool
class_name JEP_FrontendMenuBar extends MenuBar

const ICO_ADD := preload("res://addons/jeffy_events/asset/icon/Add.svg")
const ICO_LOAD := preload("res://addons/jeffy_events/asset/icon/Load.svg")
const ICO_SAVE := preload("res://addons/jeffy_events/asset/icon/Save.svg")

signal request_add_graph_modal()
signal request_load_graph(path : String)
signal request_save(graph : JEP_EventGraph)
signal request_save_all()

var file_popup : JEP_PopupMenuBuilder.GenericPopupMenu
var selected_graph : JEP_EventGraph = null

func _on_dock_ready() -> void:
	file_popup = JEP_PopupMenuBuilder\
			.create(&"File")\
			.with_input_node(owner)\
			
			.with_entry(&"Add Graph", 			create_entry().with_icon(ICO_ADD).with_callback(_on_graph_add).with_shortcut(KEY_MASK_CTRL | KEY_A))\
			.with_entry(&"Open", 				create_entry().with_icon(ICO_LOAD).with_callback(_on_graph_load))\
			.with_entry(&"Save Graph", 			create_entry().with_icon(ICO_SAVE).with_callback(_on_graph_save).with_verifier(_has_graph_selected))\
			.with_entry(&"Save Graph as...", 	create_entry().with_callback(_on_graph_save_as).with_verifier(_has_graph_selected))\
			.with_entry(&"Save All", 			create_entry().with_callback(_on_graph_save_all).with_shortcut(KEY_MASK_CTRL | KEY_S))\
			.with_divider()\
			.with_entry(&"Close", 				create_entry().with_callback(_on_graph_close))\
			
			.build()
	add_child(file_popup)
	file_popup.check_validity()

func create_entry() -> JEP_PopupMenuBuilder.EntryBuilder:
	return JEP_PopupMenuBuilder.create_entry()

func _on_graph_selected(graph : JEP_EventGraph) -> void:
	selected_graph = graph
	file_popup.check_validity()

func _has_graph_selected() -> bool:
	return selected_graph != null

func _on_graph_add() -> void:
	request_add_graph_modal.emit()

func _on_graph_save() -> void:
	request_save.emit(selected_graph)

func _on_graph_save_as() -> void:
	pass

func _on_graph_save_all() -> void:
	request_save_all.emit()

func _on_graph_load() -> void:
	# Create picker modal
	var picker := EditorFileDialog.new()
	picker.add_filter("*.tres", "Graph resource files")
	picker.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	picker.display_mode = FileDialog.DISPLAY_LIST
	
	picker.file_selected.connect(_graph_load_file_selected)
	
	add_child(picker)
	picker.popup_centered_clamped()

func _graph_load_file_selected(path : String) -> void:
	request_load_graph.emit(path)

func _on_graph_close() -> void:
	pass
