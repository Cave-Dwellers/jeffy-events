@tool
class_name JEP_EventGraphFactory extends RefCounted

## Assists in the creation of [class JEP_EventGraph]

static func create_empty() -> JEP_EventGraph:
	return Builder.start().build()

static func create_default_at_path(directory : String) -> JEP_EventGraph:
	return Builder.start()\
				.with_event_at(EventLabel.new(), Vector2.LEFT * 200)\
				.with_event_at(EventTerminator.new(), Vector2.RIGHT * 200)\
				.with_directory(directory)\
				.build_and_save()

class Builder extends RefCounted:
	var directory : StringName
	var events : Array[JEP_Event]
	
	static func start() -> Builder:
		return Builder.new()
	
	func with_directory(dir : String) -> Builder:
		self.directory = dir
		return self
	
	func with_event_at(event : JEP_Event, at : Vector2 = Vector2.ZERO) -> Builder:
		event.position = at
		return with_event(event)
	
	func with_event(event : JEP_Event) -> Builder:
		events.append(event)
		return self
	
	func build() -> JEP_EventGraph:
		var graph := JEP_EventGraph.new()
		graph._events.append_array(events)
		return graph
	
	func build_and_save() -> JEP_EventGraph:
		var graph := build()
		if !directory.is_empty():
			graph.take_over_path(directory)
			ResourceSaver.save(graph)
			
		return graph
