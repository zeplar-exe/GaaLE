@tool
extends GaaleSchema


func create_schema_assets() -> Array:
	var id_getter := func lambda(node):
		return node.name
	
	return [ 
		create_asset_from_node(%ABox, id_getter)
	]

func list_schema_scripts() -> Array:
	return [ "TestScript.gd" ]
