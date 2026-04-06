@tool
class_name JEP_DirectoryParser extends Node

## When the parser has finished finding all [class JEP_Event] within
## a provided directory, it will fire this signal
signal parsing_complete(result : Dictionary, source : JEP_Source)

func get_events_in_directory(source : JEP_Source) -> void:
	var directory := source.location
	var dict := _parse_directory(directory)
	parsing_complete.emit(dict, source)

func _parse_directory(directory : String) -> Dictionary:
	var dictionary := {}
	var dir := DirAccess.open(directory)
	
	dir.list_dir_begin()
	var file : String = dir.get_next()
	
	while file != "":
		# Create full path
		var current_file := file
		var full_path := directory.path_join(current_file)
		
		# print("Processing - %s" % full_path)
		
		# Check if file is actually a directory
		if dir.current_is_dir():
			# Get directory
			var folder_name : String = full_path.rsplit("/", false, 1)[1]
			dictionary[folder_name] = _parse_directory(full_path + "/")
			
			# We still need to advance to the next file
			file = dir.get_next()
			continue
		
		# Prematurely get next file
		file = dir.get_next()
		
		# Check file extension
		var is_script := current_file.ends_with(".gd")
		if !is_script:
			continue
		
		# Load file as gdscript
		var script := load(full_path) as GDScript
		if script == null:
			push_error("Is labeled a script, but cant be loaded | %s", full_path)
			continue
		
		# Ignore any abstract scripts
		if script.is_abstract():
			continue
		
		# Test class instance
		var instance = script.new()
		if instance is not JEP_Event:
			# Not an event...
			continue
		instance = instance as JEP_Event
		
		# Put into dict
		# print("Registered - %s" % full_path)
		dictionary[current_file] = EventInfo.new(instance._get_name(), instance._get_description(), script)
		
	dictionary.sort()
	return dictionary

class EventInfo extends RefCounted:
	
	## Simple object that holds event information
	
	var name : StringName
	var desc : StringName
	var event_script : GDScript
	
	func _init(p_name : StringName, p_desc : StringName, p_script : GDScript) -> void:
		self.name = p_name
		self.desc = p_desc
		self.event_script = p_script
