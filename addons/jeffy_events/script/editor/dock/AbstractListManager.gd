@abstract @tool
class_name JEP_AbstractListManager extends Node

@export var entry_template : Control
@export var entry_container : Control

func _on_add() -> void:
	var instance := entry_template.duplicate()
	_configure_new_entry(instance)
	entry_container.add_child(instance)

@abstract
func _configure_new_entry(instance : Control) -> void
