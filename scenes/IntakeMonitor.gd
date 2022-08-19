extends Control

signal closing()

enum ButtonID {EDIT, DELETE}
enum Column {FOOD, AMOUNT}

export var intake_name := ''
export var desired_max := 1000
export(String, 'g', 'mg') var unit := 'mg'

onready var entries: Tree = $'%Entries'
onready var delay: Timer = $MarginContainer/Delay
onready var edit_item: LineEdit = $'%EditItem'
onready var exc_screen: ColorRect = $'%ExcScreen'
onready var edit_amount: NumberEdit = $'%EditAmount'

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
	
	if true:
		var add_entries = find_node('AddEntries')
		assert(add_entries != null, "couldn't find \"AddEntries\"")
		add_entries.connect('entry_added', self, '_on_entry_added')
	
	edit_item.set_as_toplevel(true)
	edit_item.set_validate_callback(self, '_validate_item_text')
	edit_item.connect('cancelled_edit', exc_screen, 'hide')
	
	exc_screen.set_as_toplevel(true)
	exc_screen.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	edit_amount.unit = unit
	edit_amount.connect('cancelled_edit', exc_screen, 'hide')
	edit_amount.connect('focus_exited', exc_screen, 'hide')
	
	# Name of the intake being monitored
	if not intake_name.empty():
		name = intake_name
	
	# Insert each deserialize entry into the tree
	for item in _unpacked_items:
		var amount := str(item.amount)
		_on_entry_added(item.name, amount, false)
	
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
	var sum_label = $MarginContainer/AspectRatioContainer/VSplitContainer/VBoxContainer/SumLabel
	sum_label.text = "Sum %s Intake: %d / %d %s" % [name, sum, desired_max, unit]

func clear() -> void:
	if OS.has_feature('debug'):
		print('clearing file')
	entries.clear()
	_root_item = entries.create_item()
	items = {}
	_should_recalculate = true
	call_deferred('_update_amount')

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

func _validate_item_text(text: String) -> bool:
	# For the first column, the only condition is that the string isn't empty
	if edit_item.edited_column == 0:
		if text.empty():
			Globals.show_error(self, "Intake name is empty")
			return false
		return true
	
	# Get integer from string
	var unit_list := text.split(' ', false, 2)
	var s : String = unit_list[0]
	
	if not s.is_valid_integer() or unit_list.size() != 2:
		Globals.show_error(self,
			"Invalid intake amount '%s': must be a number and a unit separated by a space" % text)
		return false
	
	return true

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
		delay.start()
		_should_recalculate = true
		call_deferred('_update_amount')
		Globals.request_save()
	else:
		exc_screen.show()
		
		if column == Column.FOOD:
			edit_item.activate(entries, item, column)
		else:
			edit_amount.activate(entries, item, column)
		
		set_meta('edited_item_id', item.get_instance_id())

# Called when "EditItem" text is accepted
func _on_EditItem_edited_tree_item(new_text: String) -> void:
	var itemid : int = get_meta('edited_item_id', -1)
	assert(itemid >= 0, "invalid instance id")
	items[itemid].name = new_text
	
	exc_screen.hide()
	Globals.request_save()

func _on_EditAmount_edited_tree_item(new_text: String) -> void:
	var itemid : int = get_meta('edited_item_id', -1)
	assert(itemid >= 0, "invalid instance id")
	items[itemid].amount = int(new_text)
	
	exc_screen.hide()
	Globals.request_save()

func _on_ConfirmClose_confirmed() -> void:
	get_parent().remove_child(self)
	emit_signal('closing')
	queue_free()
