extends VBoxContainer

signal add_food_source(food_name, serving_size)
signal deactivate()

onready var food_source: LineEdit = $GridContainer/FoodSource
onready var serving_size: LineEdit = $GridContainer/ServingSize
onready var error_label: Label = $ErrorLabel

func _ready() -> void:
	food_source.set_meta('entry_name', 'food source')
	serving_size.set_meta('entry_name', 'serving size')

func _on_Add_pressed() -> void:
	var food_source_params := PoolStringArray([])
	
	for node in [food_source, serving_size]:
		if node is LineEdit:
			var le : LineEdit = node
			if le.text.empty():
				error_label.set_error("%s not provided" % le.get_meta('entry_name'))
				return
			food_source_params.append(le.text)
	
	# Compile regular expression
	var re := RegEx.new()
	var err := re.compile("[1-9][0-9]*[ \\t].+")
	if err != OK:
		get_tree().quit(1)
		return
	
	# Incorrect string format for serving size
	if not re.search(food_source_params[1]):
		error_label.set_error("The serving size must be a number followed by a space and a unit.")
		return
	
	call_deferred('deactivate')
	emit_signal('add_food_source', food_source_params[0], food_source_params[1])

func _on_Cancel_pressed() -> void:
	deactivate()

func _activate(mode: int, data = null) -> void:
	food_source.grab_focus()
	
	if mode == 1:
		assert(data is Array)
		assert(data.size() == 2, "data.size() not 2, is %d" % data.size())
		food_source.text = data[0]
		serving_size.text = data[1]

func new_entry() -> void:
	_activate(0)

func edit_entry(data: Dictionary):
	_activate(1, data)

func deactivate() -> void:
	release_focus()
	for node in get_tree().get_nodes_in_group('inputs'):
		node.text = ''
	emit_signal('deactivate')
