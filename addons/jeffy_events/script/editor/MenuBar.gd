@tool
class_name JEP_FrontendMenuBar extends MenuBar

const ICO_ADD := preload("res://addons/jeffy_events/asset/icon/Add.svg")
const ICO_LOAD := preload("res://addons/jeffy_events/asset/icon/Load.svg")
const ICO_SAVE := preload("res://addons/jeffy_events/asset/icon/Save.svg")

signal request_add_event_modal()

func _on_dock_ready() -> void:
	var popup := JEP_PopupMenuBuilder\
			.create(&"File")\
			.with_input_node(owner)\
			
			.with_entry(&"Add Event", 			create_entry().with_icon(ICO_ADD).with_callback(_on_event_add).with_shortcut(KEY_MASK_CTRL | KEY_A))\
			.with_entry(&"Open", 				create_entry().with_icon(ICO_LOAD).with_callback(_on_event_load))\
			.with_entry(&"Save Event", 			create_entry().with_icon(ICO_SAVE).with_callback(_on_event_save))\
			.with_entry(&"Save Event as...", 	create_entry().with_callback(_on_event_save_as))\
			.with_divider()\
			.with_entry(&"Close", 				create_entry().with_callback(_on_event_close))\
			
			.build()
	add_child(popup)

func create_entry() -> JEP_PopupMenuBuilder.EntryBuilder:
	return JEP_PopupMenuBuilder.create_entry()

func _on_event_add() -> void:
	request_add_event_modal.emit()

func _on_event_save() -> void:
	pass

func _on_event_save_as() -> void:
	pass

func _on_event_load() -> void:
	pass

func _on_event_close() -> void:
	pass
