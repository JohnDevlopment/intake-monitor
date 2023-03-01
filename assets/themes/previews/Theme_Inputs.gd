tool
extends PanelContainer

onready var accept_dialog: AcceptDialog = $AcceptDialog
onready var window_dialog: WindowDialog = $WindowDialog

func _ready() -> void:
	var s := 'I {0} the button!'
	if OS.has_feature('debug'):
		print(s.format(['toggled']))

func _display_popup(msg: String) -> void:
	accept_dialog.dialog_text = msg
	accept_dialog.popup_centered()

func _display_popup2(button_pressed: bool, msg: String) -> void:
	accept_dialog.dialog_text = msg.format(
		['toggled' if button_pressed else 'untoggled']
	)
	accept_dialog.popup_centered()

func _on_DisplayDlg_pressed() -> void:
	window_dialog.emit_signal('about_to_show')
	var rect : Rect2
	var winsize := get_viewport().size

	rect.size = Vector2(250, 300)
	rect.position = ((winsize - rect.size) / 2.0).floor()

	window_dialog.rect_size = rect.size
	window_dialog.rect_position = rect.position
	window_dialog.show()
