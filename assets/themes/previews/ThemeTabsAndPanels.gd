tool
extends TabContainer

func _ready() -> void:
	current_tab = 2
	
	var tree = get_node('Tab 3/Tree')
	tree.set_column_title(0, 'Column 0')
	tree.set_column_title(1, 'Column 1')
	tree.clear()
	
	var root = tree.create_item()
	var item
	
	var options := [
		{
			0: {
				text = 'Column 0'
			},
			1: {
				text = 'Column 1'
			}
		},
		{
			1: {
				text = 'I am awesome',
				checked = false
			},
			0: {
				text = 'Column 0',
				checked = true
			}
		},
		{
			0: {
				text = 'Some number',
				range = [0, 1, 0.01]
			}
		}
	]
	
	for opt in options:
		item = tree.create_item()
		
		for col in opt:
			var _opt : Dictionary = opt[col]
			
			if 'checked' in _opt:
				item.set_cell_mode(col, TreeItem.CELL_MODE_CHECK)
				item.set_editable(col, true)
				item.set_checked(col, _opt.checked)
			elif 'range' in _opt:
				item.set_cell_mode(col, TreeItem.CELL_MODE_RANGE)
				item.set_editable(col, true)
				var r : Array = _opt.range
				item.set_range_config(col, r[0], r[1], r[2])
			
			if 'text' in _opt and not ('range' in _opt):
				item.set_text(col, _opt.text)
			
