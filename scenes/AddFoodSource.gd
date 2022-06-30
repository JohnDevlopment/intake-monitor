extends VBoxContainer

signal add_food_source(food_name, serving_size)

func _ready() -> void:
	$'%FoodSource'.set_meta('entry_name', 'food source')
	$'%ServingSize'.set_meta('entry_name', 'serving size')

func _on_Add_pressed() -> void:
	var food_source_params := []
	
	for node in $GridContainer.get_children():
		if node is LineEdit:
			var le : LineEdit = node
			if le.text.empty():
				push_error("%s not provided" % le.get_meta('entry_name'))
				return
			food_source_params.append(le.text)
	
	var re := RegEx.new()
	assert(re.compile('[0-9]+') == OK)
	if not re.search(food_source_params[1]):
		push_error("A number is required for the serving size")
		return
	
	call_deferred('deactivate')
	
	emit_signal('add_food_source', food_source_params[0], food_source_params[1])

func _on_Cancel_pressed() -> void:
	deactivate()

func _activate(mode: int, data = null) -> void:
	show()
	$'%FoodSource'.grab_focus()
	
	var prefix = 'Add' if mode == 0 else 'Edit'
	$'%ActionLabel'.text = prefix + ' Food Source'
	
	if mode == 1:
		assert(data is Array)
		assert(data.size() == 2, "data.size() not 2, is %d" % data.size())
		$'%FoodSource'.text = data[0]
		$'%ServingSize'.text = data[1]

func new_entry() -> void:
	_activate(0)

func edit_entry(data: Dictionary):
	_activate(1, data)

func deactivate() -> void:
	release_focus()
	hide()
	for node in get_tree().get_nodes_in_group('inputs'):
		node.text = ''
