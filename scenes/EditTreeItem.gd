extends LineEdit

signal cancelled_edit()
signal edited_tree_item(item, column, old_text, new_text)

var edited_column := -1
var _edited_item: TreeItem
var _validate : FuncRef
var _old_text: String

func _ready() -> void:
	set_as_toplevel(true)
	hide()
	connect('text_entered', self, '_on_edited_treeitem')
	connect('hide', self, '_cancel')

## Activate this widget to edit a tree item.
func activate(tree: Tree, item: TreeItem, column: int):
	# Position this widget over the tree item, aligned with its column
	var item_rect := tree.get_item_area_rect(item, column)
	item_rect.position += tree.rect_global_position + Vector2(8, 0)
	rect_position = item_rect.position
	rect_size = item_rect.size
	
	text = item.get_text(column)
	
	_old_text = text
	edited_column = column
	_edited_item = item
	
	show_modal()
	grab_focus()

## Deactivate the widget.
func deactivate() -> void:
	release_focus()
	hide()

func set_validate_callback(node: Node, function: String) -> void:
	_validate = funcref(node, function)
	assert(_validate.is_valid())

func _cancel() -> void:
	deactivate()
	emit_signal('cancelled_edit')

# Signals

# Connected at _ready to "text_entered" signal
func _on_edited_treeitem(new_text: String) -> void:
	assert(edited_column >= 0)
	assert(is_instance_valid(_edited_item))
	
	deactivate()
	
	# Call the validation callback, cancel if it returns false
	if is_instance_valid(_validate) and _validate.is_valid():
		if not _validate.call_func(new_text):
			emit_signal('cancelled_edit')
			return
	
	# Set text of edited tree item
	var item := _edited_item
	var column := edited_column
	item.set_text(edited_column, new_text)
	
	_edited_item = null
	edited_column = -1
	
	emit_signal('edited_tree_item', item, column, _old_text, new_text)
