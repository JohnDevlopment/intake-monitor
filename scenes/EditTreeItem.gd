extends LineEdit

signal cancelled_edit()
signal edited_tree_item(new_text)

var _edited_item
var _edited_column := -1

func _ready() -> void:
	set_as_toplevel(true)
	hide()

func activate(tree: Tree, item: TreeItem, column: int):
	var item_rect := tree.get_item_area_rect(item, column)
	item_rect.position += tree.rect_global_position + Vector2(8, 0)
	rect_position = item_rect.position
	rect_size = item_rect.size
	
	text = item.get_text(column)
	_edited_column = column
	_edited_item = item
	
	show_modal()
	grab_focus()

func _on_edited_treeitem(new_text: String) -> void:
	assert(_edited_column >= 0)
	assert(_edited_item)
	
	release_focus()
	hide()
	
	var item : TreeItem = _edited_item
	_edited_item = null
	
	item.set_text(_edited_column, new_text)
	_edited_column = -1
	
	emit_signal('edited_tree_item', new_text)

func _on_EditTreeItem_hide() -> void:
	emit_signal('cancelled_edit')
