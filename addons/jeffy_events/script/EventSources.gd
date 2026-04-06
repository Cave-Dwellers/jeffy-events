@tool
class_name JEP_EventDatabase extends Resource

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
@export_storage var sources : Array[JEP_Source]

## Adds a source
func add_source(path : String, name : String) -> void:
	var source := JEP_Source.new(path, name)
	if source.validate():
		sources.append(source)
		changed.emit()

## Removes a source
func remove_source(source : JEP_Source) -> void:
	sources.erase(source)
	changed.emit()

## Validates all sources and removes broken paths
func validate() -> void:
	for source : JEP_Source in sources:
		if source.validate():
			continue
		
		printerr("%s is no longer a valid event source. Was it renamed/moved?" % source.location)
		sources.erase(source)
		changed.emit()

## Returns true if there are any sources being tracked
func has_sources() -> bool:
	return !sources.is_empty()
