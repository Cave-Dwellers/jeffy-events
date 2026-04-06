@tool
class_name JEP_ConfirmationModal extends JEP_Modal

## Fired when the user presses the "Confirm" button
signal confirmed()
## Fired when the user closes the popup or presses the "Cancel" button
signal canceled()

@export_multiline("...") var prompt : String :
	set(value) :
		prompt = value
		if is_node_ready():
			prompt_label.text = prompt
@export var confirm_text : String = "Confirm" :
	set(value) :
		confirm_text = value
		if is_node_ready():
			confirm_button.text = confirm_text
@export var cancel_text : String = "Cancel" :
	set(value) :
		cancel_text = value
		if is_node_ready():
			cancel_button.text = cancel_text

@onready var prompt_label : Label = $Panel/Margin/Sort/Prompt
@onready var confirm_button : Button = $Panel/Margin/Sort/Buttons/Confirm
@onready var cancel_button : Button = $Panel/Margin/Sort/Buttons/Cancel

var choice_made : bool = false

func _ready() -> void:
	# Set text
	prompt_label.text = prompt
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	
	# Connect signals
	confirm_button.pressed.connect(_confirm.bind())
	cancel_button.pressed.connect(_cancel.bind())

func _confirm() -> void:
	confirmed.emit()
	choice_made = true
	close()

func _cancel() -> void:
	canceled.emit()
	choice_made = true
	close()

func close() -> void:
	super.close()
	
	if !choice_made:
		canceled.emit()
