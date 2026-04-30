@tool
class_name JEP_FolderColorAPI extends RefCounted

## Provides an API for Godot's folder color feature

const SECTION_KEY : String = "file_customization"
const COLORS_KEY : String = "folder_colors"
const FOLDER_COLORS : Dictionary[String, Color] = {
	"" = Color(1.0, 1.0, 1.0),
	"red" = Color(1.0, 0.271, 0.271),
	"orange" = Color(1.0, 0.561, 0.271),
	"yellow" = Color(1.0, 0.890, 0.271),
	"green" = Color(0.502, 1.0, 0.271),
	"teal" = Color(0.271, 1.0, 0.635),
	"blue" = Color(0.271, 0.843, 1.0),
	"purple" = Color(0.502, 0.271, 1.0),
	"pink" = Color(1.0, 0.271, 0.588),
	"gray" = Color(0.616, 0.616, 0.616),
}
## Mapping of folder path to color [path string -> color key]
static var color_cache : Dictionary = {}
static var project_file : ConfigFile :
	get : return _get_project_file()

static func rebuild_cache() -> void:
	color_cache.clear()
	color_cache = project_file.get_value(SECTION_KEY, COLORS_KEY, {})

static func get_color(path : String) -> Color:
	var value : String = color_cache.get(path, "")
	return FOLDER_COLORS[value]

static func set_color(path : String, color : String) -> void:
	if !FOLDER_COLORS.keys().has(color):
		JEP_Print.error("Invalid color %s provided in folder color method" % color)
	rebuild_cache()
	color_cache.set(path, color)
	project_file.set_value(SECTION_KEY, COLORS_KEY, color_cache)

static func _get_project_file() -> ConfigFile:
	var project_file := ConfigFile.new()
	if project_file.load("res://project.godot") != OK:
		JEP_Print.error("Something went wrong with opening the Godot project file.")
		return null
	return project_file
