@tool
class_name JEP_ElementInstruction extends RefCounted

const Ports := JEP_PortInfo.Ports
var _label : String

func with_label(text : String) -> JEP_ElementInstruction:
	_label = text
	return self

class Port extends JEP_ElementInstruction:
	var _has_in : bool
	var _has_out : bool
	var _id : int
	
	func with_input() -> Port:
		_has_in = true
		return self
	
	func with_output(p_id : int) -> Port:
		_has_out = true
		_id = p_id
		return self

class DataSource extends Port:
	var _port_type : int
	
	func _init(p_label : StringName) -> void:
		_label = p_label
		_has_in = true
	
	func with_type(port_type : int) -> DataSource:
		_port_type = port_type
		return self
	
	func without_input() -> DataSource:
		_has_in = false
		return self

class Property extends Port:
	var _property : StringName
	
	func _init(p_property : StringName) -> void:
		_property = p_property
		_has_in = true
		_label = _property.capitalize()
	
	func _get_type() -> Array[int]:
		return [TYPE_NIL]
		
	func _get_port_type() -> int:
		return Ports.Flow
	
	func without_input() -> Property:
		_has_in = false
		return self

class Number extends Property:
	var _rounded : bool
	var _step : float = 1
	var _has_range : bool
	var _range_min : float
	var _range_max : float
	
	func _get_type() -> Array[int]:
		return [TYPE_INT, TYPE_FLOAT]
	
	func _get_port_type() -> int:
		return Ports.DataNumber
	
	func with_rounding() -> Number:
		_rounded = true
		return self
	
	func with_step(step : float) -> Number:
		_step = step
		return self
	
	func with_range(p_min : float, p_max : float) -> Number:
		_range_min = p_min
		_range_max = p_max
		_has_range = true
		return self

class Bool extends Property:
	func _get_type() -> Array[int]:
		return [TYPE_BOOL]
	
	func _get_port_type() -> int:
		return Ports.DataBool

class Line extends Property:
	var _max_character_count : int = -1
	
	func _get_type() -> Array[int]:
		return [TYPE_STRING, TYPE_STRING_NAME]
	
	func _get_port_type() -> int:
		return Ports.DataString
	
	func with_character_limit(limit : int) -> Line:
		_max_character_count = limit
		return self

class EnumLine extends Property:
	var _strings : PackedStringArray = []
	
	func _get_type() -> Array[int]:
		return [TYPE_STRING, TYPE_STRING_NAME]
	
	func _get_port_type() -> int:
		return Ports.DataString
	
	func with_strings(array : PackedStringArray) -> EnumLine:
		_strings = array
		return self

class CodeLine extends Property:
	var _flat : bool
	var _placeholder_text : StringName
	
	func _get_type() -> Array[int]:
		return [TYPE_STRING]
	
	func _get_port_type() -> int:
		return Ports.DataString
	
	func as_flat() -> CodeLine:
		_flat = true
		return self
	
	func with_placeholder(text : StringName) -> CodeLine:
		_placeholder_text = text
		return self
