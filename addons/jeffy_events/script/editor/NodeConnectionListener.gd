class_name JEP_NodeConnectionListener extends RefCounted

var slot : int
var on_update : Callable

func _on_update(connected : bool) -> void:
	on_update.call(connected)
