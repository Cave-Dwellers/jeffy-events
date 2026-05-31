class_name JEP_GraphContext extends RefCounted

## A basic context object used by [JEP_EventGraphPlayer],
## it is meant to provide access to non-singleton game data 
## and game objects

## The [JEP_EventGraphPlayer] that is using this context object
var graph_player : JEP_EventGraphPlayer
## The [SceneTree] execution is taking place in
var scene_tree : SceneTree :
	get : return graph_player.get_tree()
## The current scene execution is taking place in
var current_scene : Node :
	get : return graph_player.get_tree().current_scene
## The current graph execution is occuring in
var graph : JEP_EventGraph :
	get : return graph_player.graph

func _init(player : JEP_EventGraphPlayer) -> void:
	graph_player = player

## Gets a node at [param path]. Note that nodepaths
## in an event graph are relative to the node scene 
## that they are picked in, and those paths may
## lead to nothing if a graph is executed in a
## different scene
##
## If you have game objects you need access to for several
## events, it may be better to extend the [JEP_GraphContext]
## and [JEP_EventGraphPlayer] to provide those objects
func get_node_or_null(path : NodePath) -> Node:
	if path.is_empty():
		return null
	
	# Jeff - paths are defined relative to the currently
	# open scene in the editor. Sometimes the executor can be 
	# nested in an instance, so we recursively search for the 
	# root of the path.
	#
	# TODO - It might be better to have our own way of retrieving
	# objects from a graph, rather than using nodepaths. Node groups
	# might be the answer, but that may be prone to its own issues
	return JEP_NodePathResolver.find_node(graph_player.owner, path)
	
