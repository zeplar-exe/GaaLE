extends EditorInspectorPlugin

const NodeWhitelistEditor = preload("res://addons/gaale/NodeWhitelistEditor.gd")


func _can_handle(object):
	return object is GaaleLoader

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "node_whitelist":
		add_property_editor(name, NodeWhitelistEditor.new())
		
		return true
	else:
		return false
