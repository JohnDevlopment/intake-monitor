tool
extends Control

enum Column {FOOD_SOURCE, ITEM, SERVING_SIZE, AMOUNT}

#export var editor := false

onready var database: Tree = $VBoxContainer/Database
onready var add_food_source: VBoxContainer = $VBoxContainer/AddFoodSource

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
		set_meta('is_information', true)
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
	item.set_text(Column.FOOD_SOURCE, src)
	item.set_text_align(Column.FOOD_SOURCE, TreeItem.ALIGN_CENTER)
	item.set_text(Column.SERVING_SIZE, ssize)
	item.set_text_align(Column.SERVING_SIZE, TreeItem.ALIGN_CENTER)
	item.add_button(Column.FOOD_SOURCE, Globals.EDIT_BUTTON_TEXTURE)
	item.add_button(Column.SERVING_SIZE, Globals.EDIT_BUTTON_TEXTURE)
	item.add_button(Column.AMOUNT, Globals.DELETE_BUTTON_TEXTURE)
	item.set_meta('is_toplevel', true)
	var key = "{0}-{1}".format([src, ssize])
	print(key)
	_food_sources[key] = item
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

func _on_AddFoodSource_add_food_source(food_name: String,
serving_size: String) -> void:
	_add_food_source(food_name, serving_size)

func _on_ShowFSDlg_pressed() -> void:
	add_food_source.new_entry()
	$'%DimScreen'.show()

func _on_AddFoodSource_visibility_changed() -> void:
	if Engine.editor_hint: return # TODO: remove this later
	if $VBoxContainer/AddFoodSource.visible:
		$'%DimScreen'.show()
	else:
		$'%DimScreen'.hide()

func _on_Database_button_pressed(item: TreeItem, column: int, _id: int) -> void:
	match column:
		Column.AMOUNT:
			_remove_food_source(item)
		_:
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
			
			le.connect('hide', self, '_on_hiding_lineedit', [], CONNECT_ONESHOT)
			
			$ExcScreen.show()

func _on_hiding_lineedit() -> void:
	$ExcScreen.hide()

func _on_edited_tree_item(new_text: String) -> void:
	# Hide the lineedit
	var le : LineEdit = $'%EditItem'
	le.release_focus()
	le.hide()
	le.text = ''
	
	# Modify the item's text
	assert(_edited_item is TreeItem)
	var item := _edited_item as TreeItem
	item.set_text(_edited_column, new_text)
	
	_edited_item = null
	_edited_column = -1
	
	Globals.request_save()
