@tool
class_name JEP_Source extends Resource

## The directory path of the source
@export_storage var location : String
## The name of the source, either manually assigned or auto generated
@export_storage var name : String

func _init(p_location : String = "", p_name : String = "") -> void:
	self.location = p_location
	self.name = p_name

func validate() -> bool:
	return DirAccess.dir_exists_absolute(location)
