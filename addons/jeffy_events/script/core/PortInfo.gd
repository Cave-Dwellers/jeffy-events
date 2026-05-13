class_name JEP_PortInfo extends RefCounted

## Holds information and conversion tools related to
## graph ports

# TODO: allow for user to add their own port types/handling
# (maybe some kind of definition schema or something)

enum Ports {
	Flow,			# Data flow
	DataVariant,	# Can be of any data type
	DataNumber,		# Is some kind of number
	DataString,		# Is some kind of string
	DataBool,		# Is a boolean
	DataNodePath,	# Is a nodepath
	DataResource	# Is a resource or object
}

## Colors associated with each port type
const PortColors : Dictionary[int, Color] = {
	Ports.Flow : Color.WHITE,
	Ports.DataVariant : Color(0.40159997, 0.8, 0.2168, 1),
	Ports.DataNumber : Color(0.2168, 0.67440003, 0.8, 1),
	Ports.DataString : Color(0.8, 0.712, 0.2168, 1),
	Ports.DataBool : Color(0.8, 0.2168, 0.2168, 1),
	Ports.DataNodePath : Color(0.8, 0.4488, 0.2168, 1),
	Ports.DataResource : Color(0.40159997, 0.2168, 0.8, 1)
}

## Conversion between Godot data types and port types
const TypeToPort : Dictionary[int, int] = {
	TYPE_INT			: Ports.DataNumber,
	TYPE_FLOAT			: Ports.DataNumber,
	TYPE_BOOL			: Ports.DataBool,
	TYPE_STRING			: Ports.DataString,
	TYPE_STRING_NAME	: Ports.DataString,
	TYPE_NODE_PATH		: Ports.DataNodePath,
	TYPE_OBJECT			: Ports.DataResource,
}
