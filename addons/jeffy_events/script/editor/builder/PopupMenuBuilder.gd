@tool
class_name JEP_PopupMenuBuilder extends RefCounted

## Programatically creates dropdown menus

## Name of the dropdown menu node
var name : StringName
## Entries to add
var entries : Array[Configuration]
## Node we will derive shortcut input from
var focus_node : Control

static func create(node_name : StringName) -> JEP_PopupMenuBuilder:
	var builder := JEP_PopupMenuBuilder.new()
	builder.name = node_name
	return builder

static func create_entry() -> EntryBuilder:
	return EntryBuilder.create()

func with_entry(text : StringName, builder : EntryBuilder) -> JEP_PopupMenuBuilder:
	entries.append(builder.build(text))
	return self

func with_divider() -> JEP_PopupMenuBuilder:
	entries.append(EntryBuilder.create().as_divider().build(""))
	return self

func with_input_node(control : Control) -> JEP_PopupMenuBuilder:
	focus_node = control
	return self

func build() -> GenericPopupMenu:
	var popup := GenericPopupMenu.new()
	var id : int = 0
	popup.name = name
	
	for config : Configuration in entries:
		if config.divider:
			popup.add_separator(config.text, id)
			continue
		
		popup.add_item(config.text, id)
		
		if config.shortcut:
			popup.set_item_shortcut(id, config.shortcut, true)
		
		if config.icon != null:
			popup.set_item_icon(id, config.icon)
		
		if config.callback != null:
			popup.set_item_metadata(id, config.callback)
		
		id += 1
	
	focus_node.gui_input.connect(popup._gui_input)
	return popup

class EntryBuilder extends RefCounted:
	
	## Programatically builds an entry
	
	var config : Configuration
	
	static func create() -> EntryBuilder:
		var builder := EntryBuilder.new()
		builder.config = Configuration.new()
		return builder
	
	func with_icon(icon : Texture2D) -> EntryBuilder:
		config.icon = icon
		return self
	
	func with_callback(callable : Callable) -> EntryBuilder:
		config.callback = callable
		return self
	
	func with_shortcut(scankey : int) -> EntryBuilder:
		var shortcut := Shortcut.new()
		var key := InputEventKey.new()
		shortcut.events.append(key)
		
		if scankey & KEY_MASK_ALT > 0:
			key.alt_pressed = true
		if scankey & KEY_MASK_SHIFT > 0:
			key.shift_pressed = true
		if scankey & KEY_MASK_CTRL > 0:
			key.ctrl_pressed = true
		if scankey & KEY_MASK_CMD_OR_CTRL > 0:
			key.command_or_control_autoremap = true
		
		key.keycode = scankey & ~(KEY_MASK_CTRL | KEY_MASK_ALT | KEY_MASK_SHIFT | KEY_MASK_CMD_OR_CTRL)
		
		config.shortcut = shortcut
		return self
	
	func as_divider() -> EntryBuilder:
		config.divider = true
		return self
	
	func build(text : String) -> Configuration:
		config.text = text
		return config

class Configuration extends RefCounted:
	var text : StringName
	var divider : bool = false
	var icon : Texture2D
	var callback : Callable
	var shortcut : Shortcut

class GenericPopupMenu extends PopupMenu:
	
	## Adds method callback per entry
	
	func _init() -> void:
		id_pressed.connect(on_press)
	
	func _gui_input(event: InputEvent) -> void:
		if event.is_pressed():
			print(activate_item_by_event(event))
	
	func on_press(id : int) -> void:
		var index : int = get_item_index(id)
		var meta : Variant = get_item_metadata(index)
		
		if meta is Callable:
			meta.call()
