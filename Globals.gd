extends Node

signal request_save()

const DELETE_BUTTON_TEXTURE := preload('res://assets/textures/delete_icon.png')
const EDIT_BUTTON_TEXTURE := preload('res://assets/textures/pencil.png')

func request_save() -> void:
	emit_signal('request_save')
