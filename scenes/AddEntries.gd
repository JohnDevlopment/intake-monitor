extends MarginContainer

signal entry_added(name, amount)

onready var error_label : Label = get_node('%ErrorLabel')

func _on_AddButton_pressed() -> void:
	var entry_name : String = get_node('%Name').text
	if entry_name.empty():
		error_label.set_error("No name for entry provided")
		return
	
	var amount = get_node('%Amount').text
	if amount.empty():
		error_label.set_error("No amount provided")
		return
	elif not (amount as String).is_valid_integer():
		error_label.set_error("Invalid string '%s', must be an integer" % amount)
		return
	
	get_node('%Name').text = ''
	get_node('%Amount').text = ''
	
	emit_signal('entry_added', entry_name, amount)
