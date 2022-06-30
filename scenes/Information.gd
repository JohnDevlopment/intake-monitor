tool
extends Control

enum Column {FOOD_SOURCE, ITEM, SERVING_SIZE, AMOUNT}
enum ButtonID {EDIT, DELETE}

onready var database: Tree = $VBoxContainer/Database
onready var add_food_source: VBoxContainer = $VBoxContainer/AddFoodSource
onready var reference_rect: ReferenceRect = $ReferenceRect

var _tree_root : TreeItem
var _food_sources := {}
var _edited_item = null
var _edited_column := -1

func _ready() -> void:
	database.clear()
	
	# pepsi .....  1 Cup
	#       sugar  .....  58 g
	
	database.set_column_title(0, 'Food Source')
	database.set_column_title(1, 'Item')
	database.set_column_title(2, 'Serving Size')
	database.set_column_title(3, 'Amount')
	
	_tree_root = database.create_item()
	
	if not Engine.editor_hint:
		_add_food_source('Pepsi', '1 bottle (20 oz)')
		_add_intake('Pepsi-1 bottle (20 oz)', 'Sugar', 69, 'g')
		_add_intake('Pepsi-1 bottle (20 oz)', 'Sodium', 55, 'mg')
		set_meta('is_information', true)
		
		# This reference rect is used to block mouse inputs while it's visible
		reference_rect.set_as_toplevel(true)
		reference_rect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		reference_rect.margin_bottom = -133

func serialize():
	var food_sources := []
	for k in _food_sources:
		var item : TreeItem = _food_sources[k]
		var item_Contents := {
			food_source = item.get_text(Column.FOOD_SOURCE),
			serving_size = item.get_text(Column.SERVING_SIZE)
		}
		food_sources.append(item_Contents)
	
	return food_sources

func _add_food_source(src: String, ssize: String) -> void:
	var item := database.create_item(_tree_root)
	
	# Food source
	item.set_text(Column.FOOD_SOURCE, src)
	item.set_text_align(Column.FOOD_SOURCE, TreeItem.ALIGN_CENTER)
	_add_edit_button(item, Column.FOOD_SOURCE, 'food source')
	
	# Serving size
	item.set_text(Column.SERVING_SIZE, ssize)
	item.set_text_align(Column.SERVING_SIZE, TreeItem.ALIGN_CENTER)
	_add_edit_button(item, Column.SERVING_SIZE, 'serving size')
	
	_add_delete_button(item, Column.AMOUNT)
	item.set_meta('is_toplevel', true)
	_food_sources["{0}-{1}".format([src, ssize])] = item
	
	Globals.request_save()

func _add_edit_button(item: TreeItem, column: int, tooltip_name: String) -> void:
	item.add_button(column, Globals.EDIT_BUTTON_TEXTURE, ButtonID.EDIT,
					false, 'Edit ' + tooltip_name)

func _add_delete_button(item: TreeItem, column: int) -> void:
	item.add_button(column, Globals.DELETE_BUTTON_TEXTURE, ButtonID.DELETE)

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

func _remove_food_source(item: TreeItem) -> void:
	var dcopy := {}
	
	for key in _food_sources:
		var value : TreeItem = _food_sources[key]
		if value.get_instance_id() == item.get_instance_id():
			item.free()
			continue
		dcopy[key] = _food_sources[key]
	
	_food_sources = dcopy
	Globals.request_save()

func _remove_intake(item: TreeItem) -> void:
	item.free()
	Globals.request_save()

func _on_AddFoodSource_add_food_source(food_name: String,
serving_size: String) -> void:
	_add_food_source(food_name, serving_size)

func _on_ShowFSDlg_pressed() -> void:
	add_food_source.new_entry()
	var dim_screen = $'%DimScreen'
	dim_screen.show()
	dim_screen.global_position = Vector2()
	reference_rect.show()

func _on_AddFoodSource_visibility_changed() -> void:
	if Engine.editor_hint: return # TODO: remove this later
	if $VBoxContainer/AddFoodSource.visible:
		$'%DimScreen'.show()
		reference_rect.show()
	else:
		$'%DimScreen'.hide()
		reference_rect.hide()

func _on_Database_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var root = database.get_root()
	assert(root)
	
	# Id of 0 is the edit button
	if id == 0:
		# Position and size the line edit to be over the tree item
		var le : LineEdit = $'%EditItem'
		var item_rect := database.get_item_area_rect(item, column)
		item_rect.position += database.rect_global_position + Vector2(8, 0)
		le.rect_position = item_rect.position
		le.rect_size = item_rect.size
		
		_edited_item = item
		_edited_column = column
		
		# Initialize the text in the line edit and then display it
		le.text = item.get_text(column)
		le.show_modal()
		le.grab_focus()
		
		$ExcScreen.show()
		return
	
	# Remove item from tree
	if item.get_parent() == root:
		# If parent is root, is food source
		_remove_food_source(item)
	else:
		# Is intake
		_remove_intake(item)

func _on_edited_tree_item(new_text: String) -> void:
	# Hide the lineedit and the color rect
	var le : LineEdit = $'%EditItem'
	le.release_focus()
	le.hide()
	le.text = ''
	$ExcScreen.hide()
	
	# Modify the item's text
	var item : TreeItem = _edited_item
	item.set_text(_edited_column, new_text)
	
	_edited_item = null
	_edited_column = -1
	
	Globals.request_save()

func _on_AddIntakeDialog_add_intake(inktname: String, inktamt: int,
inktunit: String) -> void:
	print("Add %s: %d %s" % [inktname, inktamt, inktunit])
