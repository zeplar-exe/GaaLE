extends EditorInspectorPlugin

func _can_handle(object):
	return object is GaaleSchema

func _parse_begin(object):
	var button = Button.new()
	button.text = "Export Schema"
	button.connect("pressed", Callable(self, "_on_export_pressed").bind(object as GaaleSchema))
	
	add_custom_control(button)

func _on_export_pressed(object):
	object.call("export")
