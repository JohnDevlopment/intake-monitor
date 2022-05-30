extends MarginContainer

signal request_save()
signal closing()

const DELETE_BUTTON_TEXTURE := preload('res://assets/textures/delete_icon.png')

export var intake_name := ''
export var desired_max := 1000
export(String, 'g', 'mg') var unit := 'mg'

onready var entries : Tree = get_node('%Entries')
onready var sum_label = $AspectRatioContainer/VSplitContainer/VBoxContainer/SumLabel
onready var delay: Timer = $Delay

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
	
	if not intake_name.empty():
		name = intake_name
	
	for item in _unpacked_items:
		_on_entry_added(item.name, str(item.amount), false)
	
	_should_recalculate = true
	call_deferred('_update_amount')
	
	set_meta('is_intake', true)

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

func _calculate_sum() -> void:
	sum = 0
	for id in items:
		var item = items[id]
		sum += item['amount']
	if OS.has_feature('debug'):
		print("calculate sum for %s is %d" % [intake_name, sum])

func _update_amount() -> void:
	if _should_recalculate:
		_should_recalculate = false
		_calculate_sum()
	sum_label.text = "Sum %s Intake: %d / %d %s" % [name, sum, desired_max, unit]

func _on_entry_added(_name: String, amount: String, update: bool = true) -> void:
	var item := entries.create_item(entries)
	items[item.get_instance_id()] = {
		name = _name,
		amount = amount.to_int()
	}
	item.set_text(0, _name)
	item.set_text(1, "%s %s" % [amount, unit])
	item.add_button(1, DELETE_BUTTON_TEXTURE)
	if update:
		_should_recalculate = true
	_update_amount()
	emit_signal('request_save')

func _on_Entries_button_pressed(item: TreeItem, column: int, _id: int) -> void:
	if not delay.is_stopped(): return
	var item_id := item.get_instance_id()
	if column == 1:
		items.erase(item_id)
		item.free()
		call_deferred('_update_amount')
		delay.start()
		emit_signal('request_save')

func _on_ConfirmationDialog_confirmed() -> void:
	get_parent().remove_child(self)
	emit_signal('closing')
	queue_free()
