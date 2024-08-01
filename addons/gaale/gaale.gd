@tool
extends EditorPlugin

var export_button_plugin = preload("res://addons/gaale/export_schema_button.gd").new()
var loader_whitelist_plugin = preload("res://addons/gaale/loader_whitelist.gd").new()

var submenu: PopupMenu

func _enter_tree():
	submenu = PopupMenu.new()
	submenu.add_item("Import Schema", 0)
	submenu.add_item("Export Level", 1)
	
	var on_id_pressed := func lambda(id):
		var control = Control.new()
		var dialog = EditorFileDialog.new()
		
		control.add_child(dialog)
		
		if id == 0:
			dialog.mode = FileDialog.FILE_MODE_OPEN_FILE
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.add_filter("*.gaale")
			dialog.connect("file_selected", load_schema)
		elif id == 1:
			dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.connect("file_selected", export_level)
		
		dialog.size = DisplayServer.screen_get_size() * 0.5
		
		add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, control)
		dialog.popup_centered()
	
	submenu.connect("id_pressed", on_id_pressed)
	
	add_tool_submenu_item("Gaale", submenu)
	
	add_inspector_plugin(export_button_plugin)
	add_inspector_plugin(loader_whitelist_plugin)

func create_asset_node(asset):
	var root = ClassDB.instantiate(asset["type"])
	
	var get_property_names := func lambda(node):
		var names = []
		var property_list = node.get_property_list()
		
		for property in property_list:
			names.append(property["name"])
			
		return names
	
	var property_list = get_property_names.call(root)
	
	for property in asset["properties"]:
		var property_data = asset["properties"][property]
		var value = property_data["value"]
		var type = property_data["type"]
		
		if type != TYPE_STRING and typeof(value) == TYPE_STRING:
			if type == TYPE_VECTOR2:
				value = value.trim_prefix("(").trim_suffix(")").split(",")
				var x = float(value[0].strip_edges())
				var y = float(value[1].strip_edges())
				value = Vector2(x, y)
			elif type == TYPE_VECTOR2I:
				value = value.trim_prefix("(").trim_suffix(")").split(",")
				var x = int(value[0].strip_edges())
				var y = int(value[1].strip_edges())
				value = Vector2i(x, y)
			elif type == TYPE_VECTOR3:
				value = value.trim_prefix("(").trim_suffix(")").split(",")
				var x = float(value[0].strip_edges())
				var y = float(value[1].strip_edges())
				var z = float(value[2].strip_edges())
				value = Vector3(x, y, z)
			elif type == TYPE_VECTOR3I:
				value = value.trim_prefix("(").trim_suffix(")").split(",")
				var x = int(value[0].strip_edges())
				var y = int(value[1].strip_edges())
				var z = int(value[2].strip_edges())
				value = Vector3i(x, y, z)
			else:
				value = str_to_var(value)
		
		root.name = asset["id"]
		
		if property_list.has(property):
			root.set(property, value)
		else:
			root.set_meta(property, value)
	
	root.set_meta("id", asset["id"])
	
	if asset.get("script"):
		root.set_script(asset["script"])
	
	for child in asset["children"]:
		root.add_child(create_asset_node.call(child))
	
	return root

func load_schema(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var schema = JSON.parse_string(file.get_as_text())
	
	var dir = DirAccess.open("res://addons/gaale")
	
	var dir_path = "./import".path_join(schema["name"])
	dir.make_dir_recursive(dir_path)
	dir.change_dir(dir_path)
	
	var path_root = dir.get_current_dir()
	
	dir.make_dir_recursive("assets/scripts")
	dir.make_dir("scripts")
	
	for asset in schema["schema"]["assets"]:
		if ClassDB.can_instantiate(asset["type"]):
			var packed = PackedScene.new()
			packed.pack(create_asset_node(asset))
			
			ResourceSaver.save(packed, path_root.path_join("assets").path_join(asset["id"] + ".tscn"))
		else:
			push_error("Class " + asset["type"] + " does not exist. Skipping asset " + asset["id"])
	
	for script in schema["schema"]["scripts"]:
		file = FileAccess.open(path_root.path_join("scripts").path_join(script), FileAccess.WRITE)
		file.store_string("extends Node")
	
	for script in schema["resources"]["asset_scripts"]:
		file = FileAccess.open(path_root + "/assets/scripts/" + script, FileAccess.WRITE)
		file.store_string(schema["resources"]["asset_scripts"][script])

func export_level(file_path):
	var data = {}
	
	# bru
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	print("Successfully exported level to " + file_path)

func _exit_tree():
	remove_tool_menu_item("Gaale")
	submenu.queue_free()
	
	remove_inspector_plugin(export_button_plugin)
	remove_inspector_plugin(loader_whitelist_plugin)
