class_name JEP_NodePathResolver extends RefCounted

static func resolve_node_path_for_graph(path : NodePath) -> Node:
	var st : SceneTree = Engine.get_main_loop() as SceneTree
	return find_node(st.current_scene, path)

static func find_node(from : Node, path : NodePath) -> Node:
	var node : Node = from.get_node_or_null(path)
	if node:
		return node
	
	if !from.get_parent():
		return null
	return find_node(from.get_parent(), path)
