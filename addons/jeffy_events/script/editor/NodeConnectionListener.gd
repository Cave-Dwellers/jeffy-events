class_name JEP_NodeConnectionListener extends RefCounted

var slot : int
var input_ref : WeakRef
var on_update : Callable

## Returns true if the update is successful, false if otherwise
func _on_update(connected : bool) -> bool:
	var input : Control = input_ref.get_ref()
	if !input:
		return false
		
	on_update.call(input, connected)
	return true
