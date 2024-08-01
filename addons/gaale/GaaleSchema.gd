@tool

extends Node
class_name GaaleSchema

@export var schema_file_name: String = "schema.gaale"
@export var schema_name: String = "Unnamed Schema"

enum EXPORT_LOCATION { PROJECT, APPDATA }
@export var export_location: EXPORT_LOCATION

func export():
	var assets = create_schema_assets()
	var scripts = list_schema_scripts()
	
	for i in range(scripts.size() - 1, -1, -1):
		var name = scripts[i]
		
		if not (name.ends_with(".gd") or name.ends_with(".cs")):
			push_error("Script " + name + " does not end with .gd or .cs. Skipping.")
			scripts.remove_at(i)
	
	var schema = {
		"name": schema_name,
		"schema": { "assets": assets, "scripts": scripts },
		"resources": { "asset_scripts": [] }
	}
	
	for asset in schema["schema"]["assets"]:
		var script_path = asset.get("script")
		
		if script_path and not schema["scripts"].has(script_path):
			var script = ResourceLoader.load(script_path)
			
			schema["resources"]["asset_scripts"][script_path] = script.source_code
	
	var location = "res" if export_location == EXPORT_LOCATION.PROJECT else "user"
	var file_path = location + "://" + schema_file_name
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(schema))
	file.close()
	
	print("Successfully exported to " + ProjectSettings.globalize_path(file_path))

func create_property(value: Variant):
	return { "type": typeof(value), "value": value }

func create_asset(id: String, type: String, script: String="", properties: Dictionary={}, children: Array=[]):
	if script == "":
		return { "id": id, "type": type, "properties": properties, "children": children }
	else:
		return { "id": id, "type": type, "script": script, "properties": properties, "children": children }

func create_asset_from_scene(
	scene_path: String, 
	id_getter: Callable,
	include_scripts: bool=false, 
	property_filter: Callable=Callable(self, "_property_filter_dummy"),
	script_filter: Callable=Callable(self, "_script_filter_dummy")):
	
	var root = ResourceLoader.load(scene_path).instantiate()
	
	return create_asset_from_node(root, id_getter, include_scripts, true, property_filter, script_filter)

func create_asset_from_node(
	node: Node, 
	id_getter: Callable,
	include_script: bool=false, 
	recursive: bool=true,
	property_filter: Callable=Callable(self, "_property_filter_dummy"),
	script_filter: Callable=Callable(self, "_script_filter_dummy")):
	
	var properties = {}
	var children = []
	var script = ""
	
	var script_obj = node.get_script()
	
	if include_script and script_obj:
		var script_path = script_obj.get_file()
		
		if script_filter.call(node, script_path):
			script = script_path
	
	for property in node.get_property_list():
		var name = property["name"]
		if name != "name" and property_filter.call(node, name):
			properties[property] = create_property(node.get(name))
	
	if (recursive):
		for child in node.get_children():
			var child_asset = create_asset_from_node(child, id_getter, include_script, recursive, property_filter, script_filter)
			
			children.append(child_asset)
	
	return create_asset(id_getter.call(node), node.get_class(), script, properties, children)

func create_schema_assets() -> Array:
	push_error("GaaleSchema.create_schema_assets() function not implemented.")
	
	return []

func list_schema_scripts() -> Array:
	push_error("GaaleSchema.list_schema_scripts() function not implemented.")
	
	return []

func _property_filter_dummy(x1, x2):
	return false

func _script_filter_dummy(x1, x2):
	return false
