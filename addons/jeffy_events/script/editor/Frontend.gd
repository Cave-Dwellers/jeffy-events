@tool
class_name JEP_Frontend extends Control

## Main frontend class

## Fired when the frontend is created as part of the
## editor dock
signal dock_ready()
## Fired from the editor, happens when user manually saves
## the current scene
signal save_requested()

func _dock_ready() -> void:
	dock_ready.emit()
