extends MarginContainer

signal closing()

enum ButtonID {EDIT, DELETE}

export var intake_name := ''
export var desired_max := 1000
export(String, 'g', 'mg') var unit := 'mg'

onready var entries : Tree = get_node('%Entries')
onready var sum_label = $AspectRatioContainer/VSplitContainer/VBoxContainer/SumLabel
onready var delay: Timer = $Delay
onready var edit_item: LineEdit = find_node('EditItem')

var items := {}
var sum := 0

var _root_item : TreeItem
var _unpacked_items := []
var _should_recalculate := false

func _ready() -> void:
	_root_item = entries.create_item()
	_root_item.set_text(0, "Items")
	
	entries.set_column_title(0, "Food/Drink")
	entries.set_column_title(1, "Amount")
	
	edit_item.set_as_toplevel(true)
	
	# Name of the intake being monitored
	if not intake_name.empty():
		name = intake_name
	
	# Insert each deserialize entry into the tree
	for item in _unpacked_items:
		_on_entry_added(item.name, str(item.amount), false)
	
	_should_recalculate = true
	call_deferred('_update_amount')
	
	set_meta('is_intake', true)

func _calculate_sum() -> void:
	sum = 0
	for id in items:
		var item = items[id]
		sum += item['amount']
	if OS.has_feature('debug'):
		print("calculated sum for %s is %d" % [intake_name, sum])

func _update_amount() -> void:
	if _should_recalculate:
		_should_recalculate = false
		_calculate_sum()
	sum_label.text = "Sum %s Intake: %d / %d %s" % [name, sum, desired_max, unit]

func close() -> void:
	$ConfirmClose.popup_centered(Vector2(380, 230))

func deserialize(data: Dictionary) -> void:
	intake_name = data.name
	desired_max = data.cap
	unit = data.unit
	
	for item in data.items:
		_unpacked_items = data.items

func serialize() -> Dictionary:
	var data := {
		name = intake_name,
		cap = desired_max,
		unit = unit,
		items = []
	}
	
	for id in items:
		(data.items as Array).push_back(items[id])
	
	return data

func _on_entry_added(_name: String, amount: String, update: bool = true) -> void:
	# Create the tree item and insert the column texts
	var item := entries.create_item(entries)
	items[item.get_instance_id()] = {
		name = _name,
		amount = amount.to_int()
	}
	item.set_text(0, _name)
	item.set_text(1, "%s %s" % [amount, unit])
	item.add_button(0, Globals.EDIT_BUTTON_TEXTURE, ButtonID.EDIT)
	item.add_button(1, Globals.EDIT_BUTTON_TEXTURE, ButtonID.EDIT)
	item.add_button(1, Globals.DELETE_BUTTON_TEXTURE, ButtonID.DELETE)
	
	# Recalculate sum
	if update:
		_should_recalculate = true
	_update_amount()
	
	Globals.request_save()

func _on_Entries_button_pressed(item: TreeItem, column: int, id: int) -> void:
	if not delay.is_stopped(): return
	
	if id == ButtonID.DELETE:
		# Delete entry
		var item_id := item.get_instance_id()
		items.erase(item_id)
		item.free()
		call_deferred('_update_amount')
		delay.start()
		Globals.request_save()
		_should_recalculate = true
	else:
		edit_item.activate(entries, item, column)
		set_meta('edited_item_id', item.get_instance_id())
		$ExcScreen.show()

func _on_ConfirmationDialog_confirmed() -> void:
	get_parent().remove_child(self)
	emit_signal('closing')
	queue_free()

func _on_EditItem_edited_tree_item(new_text: String) -> void:
	$ExcScreen.hide()
	var itemid : int = get_meta('edited_item_id', -1)
	assert(itemid >= 0, "invalid instance id")
	
	# Get integer from string
	var re := RegEx.new()
	assert(re.compile("[0-9]+") == OK)
	
	var rematch = re.search(new_text)
	assert(rematch is RegExMatch, "regular expression did not match")
	if rematch is RegExMatch:
		var matched_string : String = rematch.get_string()
		assert(not matched_string.empty())
		items[itemid].amount = int(matched_string)
	
	Globals.request_save()

func _on_EditItem_cancelled_edit() -> void:
	$ExcScreen.hide()
