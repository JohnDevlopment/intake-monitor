extends NumberEdit

signal edited_tree_item(new_text)

var _edited_item = null
var edited_column := -1
var unit := ''

func _ready() -> void:
	set_as_toplevel(true)
	hide()
	connect('edit_confirmed', self, '_edit_treeitem')

func activate(tree: Tree, item: TreeItem, column: int):
	var item_rect := tree.get_item_area_rect(item, column)
	item_rect.position += tree.rect_global_position + Vector2(8, 0)
	rect_position = item_rect.position
	rect_size = item_rect.size

	set_value(int(item.get_text(column)))
	edited_column = column
	_edited_item = item

	show_modal()
	grab_focus()
	_on_focus_in()

func _edit_treeitem(new_text: String) -> void:
	assert(_edited_item != null)
	var item : TreeItem = _edited_item

	assert(edited_column >= 0)
	item.set_text(edited_column, "%s %s" % [new_text, unit])

	release_focus()
	hide()

	_edited_item = null
	edited_column = -1

	emit_signal('edited_tree_item', new_text)
