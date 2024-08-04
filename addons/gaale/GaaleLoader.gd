@tool

extends Node
class_name GaaleLoader

@export var allow_scripts: bool = false
@export var node_whitelist: Dictionary = {}

func map_asset(id: String, properties: Dictionary) -> Node:
	push_error("GaaleLoader.map_asset(id, properties) function not implemented.")
	
	return null

func map_script(id) -> String:
	push_error("GaaleLoader.map_script(id) function not implemented.")
	
	return ""

func construct_node(type, properties):
	var root = ClassDB.instantiate(type)
	
	var get_property_names := func lambda(node):
		var names = []
		var property_list = node.get_property_list()
		
		for property in property_list:
			names.append(property["name"])
			
		return names
	
	var property_list = get_property_names.call(root)
	
	for property in properties:
		var property_data = properties[property]
		var value = property_data["value"]
		
		if property_list.has(property):
			root.set(property, value)
		else:
			root.set_meta(property, value)
	
	return root

func create_packed_scene(level: Dictionary) -> PackedScene:
	var packed = PackedScene.new()
	packed.pack(create_scene(level))
	
	return packed

func create_scene(level: Dictionary) -> Node:
	return _create_node(level["root"])

func _create_node(node: Dictionary):
	var node_inst
	
	if node["id"] != "":
		node_inst = map_asset(node["id"], node["properties"])
	else:
		if node_whitelist.get(node["type"]):
			node_inst = construct_node(node["type"], node["properties"])
	
	if not node_inst:
		return null
	
	var script_id = node["script"]
	
	if allow_scripts and script_id:
		node_inst.set_script(map_script(script_id))
	
	for nested in node["children"]:
		var nested_inst = _create_node(nested)
		
		node_inst.add_child(nested_inst)
	
	return node_inst
