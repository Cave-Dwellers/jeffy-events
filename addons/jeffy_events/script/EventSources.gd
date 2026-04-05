class_name JEP_EventSources extends Resource

# !!!WARNING!!! DO NOT MODIFY THIS SCRIPT !!!WARNING!!!
# To add event sources, please use the frontend panel on 
# the bottom dock. If you do not see it, please make sure 
# you've properly enabled the JeffyEvents plugin

## Validates and stores directory paths that contain
## event scripts. 
##
## You can add new paths using the frontend.
## Removing a source will not remove associated events from
## existing graphs, sources are only used to notify the frontend
## that event scripts exist at the given directories.

## All tracked sources
@export_storage var sources : Array[Source]

## Adds a source
func add_source(path : String, name : String) -> void:
	var source := Source.new(path, name)
	if source.validate():
		sources.append(source)

## Removes a source
func remove_source(path : String) -> void:
	for source : Source in sources:
		if source.location != path:
			continue
			
		sources.erase(source)
		break

## Validates all sources and removes broken paths
func validate() -> void:
	for source : Source in sources:
		if source.validate():
			continue
		
		push_warning("%s is no longer a valid event source. Was it renamed/moved?", source.location)
		sources.erase(source)

class Source extends Resource:
	## The directory path of the source
	@export_storage var location : String
	## The name of the source, either manually assigned or auto generated
	@export_storage var name : String
	
	func _init(p_location : String, p_name : String) -> void:
		self.location = p_location
		self.name = p_name
	
	func validate() -> bool:
		return DirAccess.dir_exists_absolute(location)
	
