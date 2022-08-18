extends LineEdit

signal cancelled_edit()
signal edited_tree_item(new_text)

var _edited_item
var edited_column := -1
var _validate : FuncRef

func _ready() -> void:
	set_as_toplevel(true)
	hide()
	connect('text_entered', self, '_on_edited_treeitem')
	connect('hide', self, '_cancel')

func activate(tree: Tree, item: TreeItem, column: int):
	var item_rect := tree.get_item_area_rect(item, column)
	item_rect.position += tree.rect_global_position + Vector2(8, 0)
	rect_position = item_rect.position
	rect_size = item_rect.size
	
	text = item.get_text(column)
	edited_column = column
	_edited_item = item
	
	show_modal()
	grab_focus()

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
	assert(_edited_item)
	
	deactivate()
	
	if is_instance_valid(_validate) and _validate.is_valid():
		if not _validate.call_func(new_text):
			emit_signal('cancelled_edit')
			return
	
	var item : TreeItem = _edited_item
	item.set_text(edited_column, new_text)
	_edited_item = null
	edited_column = -1
	
	emit_signal('edited_tree_item', new_text)
