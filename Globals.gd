extends Node

signal request_save()

const DELETE_BUTTON_TEXTURE := preload('res://assets/textures/delete_icon.png')
const EDIT_BUTTON_TEXTURE := preload('res://assets/textures/pencil.png')
const ADD_BUTTON_TEXTURE := preload('res://assets/textures/add_icon.png')

func request_save() -> void:
	emit_signal('request_save')

func show_error(parent: Node, message: String) -> void:
	assert(is_instance_valid(parent) and parent.is_inside_tree(), "invalid parent")
	var dlg := AcceptDialog.new()
	dlg.dialog_text = message
	dlg.connect('hide', self, '_on_dialog_hide', [dlg])
	parent.add_child(dlg)
	dlg.popup_centered()

func _on_dialog_hide(dlg: Node) -> void:
	dlg.queue_free()
