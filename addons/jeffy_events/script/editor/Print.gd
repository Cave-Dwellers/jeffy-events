@tool
class_name JEP_Print extends RefCounted

## Convenient methods for printing and pushing toasts

static var toast : EditorToaster :
	get : return EditorInterface.get_editor_toaster()

static func toast_info(msg : String, tip : String = "") -> void:
	toast.push_toast(msg, EditorToaster.SEVERITY_INFO, tip)

static func toast_warn(msg : String, tip : String = "") -> void:
	toast.push_toast(msg, EditorToaster.SEVERITY_WARNING, tip)

static func toast_error(msg : String, tip : String = "") -> void:
	toast.push_toast(msg, EditorToaster.SEVERITY_ERROR, tip)

static func info(msg : String) -> void:
	print_rich("[color=grey][b]JeffyEvents |[/b] %s[/color]" % msg)

static func warn(msg : String) -> void:
	print_rich("[color=orange][b]JeffyEvents WARNING |[/b] %s[/color]" % msg)

static func error(msg : String) -> void:
	print_rich("[color=red][b]JeffyEvents ERROR |[/b] %s[/color]" % msg)
