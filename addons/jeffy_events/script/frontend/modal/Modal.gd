class_name JEP_Modal extends Window

## Basic modal base for frontend

func _ready() -> void:
	# Connect signals
	close_requested.connect(close.bind())

## Opens the modal
func open() -> void:
	show()

## Closes the modal
func close() -> void:
	# Dont remove modal windows, just hide them
	hide()
	_reset_state()

## Resets the state of the modal (data, elements, etc)
func _reset_state() -> void:
	pass
