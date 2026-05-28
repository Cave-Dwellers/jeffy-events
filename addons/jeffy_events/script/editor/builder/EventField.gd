@abstract
@tool
class_name JEP_EventField extends RefCounted

## Wrapper for an event node property field

var event : JEP_Event
var property : StringName
var undo_redo : UndoRedo

var field : Control

func _init(_event : JEP_Event, _property : StringName, _undo_redo : UndoRedo) -> void:
	self.event = _event
	self.property = _property
	self.undo_redo = _undo_redo

## Sets common values on node
func configure_input(node : Control) -> Control:
	node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

## Sets the property's value
func _set_value(value : Variant) -> void:
	var current : Variant = event.get(property)
	undo_redo.create_action("Set %s value" % property)
	undo_redo.add_do_property(event, property, value)
	undo_redo.add_do_method(_check_instance)
	undo_redo.add_do_method(event.emit_changed)
	undo_redo.add_undo_property(event, property, current)
	undo_redo.add_undo_method(_check_instance)
	undo_redo.add_undo_method(event.emit_changed)
	undo_redo.commit_action()

func _create_from_instruction(instruction : JEP_ElementInstruction, node : JEP_EventGraphNode) -> Control:
	node.add_field(self)
	return field

func _check_instance() -> void:
	if !is_instance_valid(field):
		return
	
	_on_value_changed()

@abstract
## Called when value gets changed
func _on_value_changed() -> void

@abstract
## Called when something connects or disconnects from this event
func _connection_status_updated(connected : bool) -> void
