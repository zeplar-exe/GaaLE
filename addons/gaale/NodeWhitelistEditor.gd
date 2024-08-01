extends EditorProperty

var vbox = VBoxContainer.new()
var current_value = {}
var updating = false

func _init():
	add_child(vbox)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(250, 350)
	
	vbox.add_child(scroll)
	
	var scroll_vbox = VBoxContainer.new()
	
	scroll.add_child(scroll_vbox)
	
	var classes = ClassDB.get_class_list()
	
	for c in classes:
		current_value[c] = false
		
		var hbox = HBoxContainer.new()
		
		var checkbox = CheckBox.new()
		var label = Label.new()
		label.text = c
		
		var on_check := func lambda(checked, c):
			if updating:
				return
			
			current_value[c] = checked
			emit_changed(get_edited_property(), current_value)
		
		checkbox.connect("toggled", Callable(on_check).bind(c))
		
		scroll_vbox.add_child(hbox)
		hbox.add_child(checkbox)
		hbox.add_child(label)
