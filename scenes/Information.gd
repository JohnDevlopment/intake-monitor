tool
extends Control

enum Column {FOOD_SOURCE, ITEM, SERVING_SIZE, AMOUNT}
enum ButtonID {EDIT, DELETE, ADD}

onready var database: Tree = $VBoxContainer/Database
onready var exc_screen: ColorRect = $'%ExcScreen'
onready var add_fs_dlg: WindowDialog = $AddFSDlg
onready var edit_item: LineEdit = $'%EditItem'

var _tree_root : TreeItem
var _food_sources := {
	# Format:
	#   key: String, format: "FOOD SOURCE-SERVING SIZE"
	#   value: TreeItem
}

class FoodSourceTreeItem:
	enum Column {FOOD_SOURCE, ITEM, SERVING_SIZE, AMOUNT}
	var _item: TreeItem

	func _init(item: TreeItem) -> void:
		assert(is_instance_valid(item))
		_item = item

	func get_food_source() -> String:
		return _item.get_text(Column.FOOD_SOURCE)

	func get_serving_size() -> String:
		return _item.get_text(Column.SERVING_SIZE)

func _ready() -> void:
	database.clear()

	database.set_column_title(0, 'Food Source')
	database.set_column_title(1, 'Item')
	database.set_column_title(2, 'Serving Size')
	database.set_column_title(3, 'Amount')

	_tree_root = database.create_item()

	if not Engine.editor_hint:
		set_meta('is_information', true)

		exc_screen.set_as_toplevel(true)
		exc_screen.set_anchors_and_margins_preset(Control.PRESET_WIDE)

		edit_item.connect('cancelled_edit', exc_screen, 'hide')
		edit_item.connect('edited_tree_item', self, '_on_edited_tree_item')

		$AddIntakeDialog.connect('popup_hide', exc_screen, 'hide')
		add_fs_dlg.connect('popup_hide', exc_screen, 'hide')

func deserialize(data: Array) -> void:
	for foodsrc in data:
		var item := _add_food_source(foodsrc.food_source, foodsrc.serving_size)
		for intake in foodsrc.intakes:
			var amountlst := (intake.amount as String).split(' ', false)
			_add_intake(_get_item_key(item), intake.item,
									int(amountlst[0]), amountlst[1])
			pass

func serialize():
	var food_sources := []
	for k in _food_sources:
		var item : TreeItem = _food_sources[k]
		var item_Contents := {
			food_source = item.get_text(Column.FOOD_SOURCE),
			serving_size = item.get_text(Column.SERVING_SIZE),
			intakes = _get_intakes(item)
		}
		food_sources.append(item_Contents)

	return food_sources

func _add_delete_button(item: TreeItem, column: int) -> void:
	item.add_button(column, Globals.DELETE_BUTTON_TEXTURE, ButtonID.DELETE)

func _add_edit_button(item: TreeItem, column: int, tooltip_name: String) -> void:
	item.add_button(column, Globals.EDIT_BUTTON_TEXTURE, ButtonID.EDIT,
					false, 'Edit ' + tooltip_name)

func _add_food_source(src: String, ssize: String) -> TreeItem:
	var item := database.create_item(_tree_root)

	# Food source
	item.set_text(Column.FOOD_SOURCE, src)
	item.set_text_align(Column.FOOD_SOURCE, TreeItem.ALIGN_CENTER)
	item.add_button(Column.FOOD_SOURCE, Globals.ADD_BUTTON_TEXTURE,
					ButtonID.ADD, false, "Add intake for " + src)
	_add_edit_button(item, Column.FOOD_SOURCE, 'food source')

	# Serving size
	item.set_text(Column.SERVING_SIZE, ssize)
	item.set_text_align(Column.SERVING_SIZE, TreeItem.ALIGN_CENTER)
	_add_edit_button(item, Column.SERVING_SIZE, 'serving size')

	# Amount
	_add_delete_button(item, Column.AMOUNT)
	item.set_meta('is_toplevel', true)
	_food_sources[_generate_food_sources_key(src, ssize)] = item

	Globals.request_save()

	return item

func _generate_food_sources_key(food_source: String, serving_size: String) -> String:
	return "{0}-{1}".format([food_source, serving_size])

func _add_intake(foodsrc: String, intake: String, amount: int, unit: String) -> void:
	assert(foodsrc in _food_sources, "unknown key '%s'" % foodsrc)
	var parent : TreeItem = _food_sources[foodsrc]
	var child := database.create_item(parent)
	child.set_text(Column.ITEM, intake)
	child.set_text(Column.AMOUNT, "%d %s" % [amount, unit])
	_add_edit_button(child, Column.ITEM, 'intake item')
	_add_edit_button(child, Column.AMOUNT, 'intake amount')
	_add_delete_button(child, Column.AMOUNT)

	Globals.request_save()

func _get_intakes(item: TreeItem):
	var first_child = item.get_children()
	if not first_child: return []

	var next_child : TreeItem = first_child
	var res := []
	while is_instance_valid(next_child) and next_child.get_parent() == item:
		res.append({
			item = (next_child as TreeItem).get_text(Column.ITEM),
			amount = (next_child as TreeItem).get_text(Column.AMOUNT)
		})
		next_child = next_child.get_next_visible()

	return res

func _get_item_key(item: TreeItem) -> String:
	var fsrc : String = item.get_text(Column.FOOD_SOURCE)
	var fsiz : String = item.get_text(Column.SERVING_SIZE)
	return "%s-%s" % [fsrc, fsiz]

func _remove_food_source(item: TreeItem) -> void:
	var dcopy := {}
	var freed = null

	for key in _food_sources:
		var value : TreeItem = _food_sources[key]
		if value.get_instance_id() == item.get_instance_id():
			freed = item
			continue
		dcopy[key] = _food_sources[key]

	if freed:
		(freed as TreeItem).free()

	_food_sources = dcopy
	Globals.request_save()

func _remove_intake(item: TreeItem) -> void:
	item.free()
	Globals.request_save()

# Signals

func _on_AddFoodSource_add_food_source(food_name: String,
serving_size: String) -> void:
	_add_food_source(food_name, serving_size)

func _on_AddIntakeDialog_add_intake(inktname: String, inktamt: int,
inktunit: String) -> void:
	if OS.has_feature('debug'):
		print("Add %s: %d %s" % [inktname, inktamt, inktunit])
	assert(has_meta('item_key'), "missing key: 'item_key'")
	_add_intake(get_meta('item_key'), inktname, inktamt, inktunit)

func _on_Database_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var root = database.get_root()
	assert(root)

	if id == ButtonID.EDIT:
		# Position and size the line edit to be over the tree item
		var key := _get_item_key(item)
		assert(key in _food_sources)
		edit_item.set_meta('_dict_key', key)
		edit_item.activate(database, item, column)
		exc_screen.show()
		return
	elif id == ButtonID.ADD:
		set_meta('item_key', _get_item_key(item))
		$AddIntakeDialog.popup_custom()
		exc_screen.show()
		return

	# Remove item from tree
	if item.get_parent() == root:
		_remove_food_source(item)
	else:
		_remove_intake(item)

func _on_ShowFSDlg_pressed() -> void:
	exc_screen.show()
	add_fs_dlg.popup_centered()

func _on_edited_tree_item(item: TreeItem, column: int, old_text: String, new_text: String) -> void:
	if column in [Column.FOOD_SOURCE, Column.SERVING_SIZE]:
		var key: String = edit_item.get_meta('_dict_key', '')
		assert(key != '')
	
		if old_text != new_text:
			var foodsrcobj := FoodSourceTreeItem.new(item)
			var new_key = _generate_food_sources_key(
				foodsrcobj.get_food_source(),
				foodsrcobj.get_serving_size()
			)
			_food_sources.erase(key)
			_food_sources[new_key] = item
	
			# TODO: write function that prints in debug mode
			if OS.has_feature('debug'):
				print("'%s' changed to '%s'" % [old_text, new_text])
				print("key '%s' changed to '%s'" % [key, new_key])

	exc_screen.hide()
	Globals.request_save()
