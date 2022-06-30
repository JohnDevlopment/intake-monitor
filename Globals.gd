extends Node

signal request_save()

const DELETE_BUTTON_TEXTURE := preload('res://assets/textures/delete_icon.png')
const EDIT_BUTTON_TEXTURE := preload('res://assets/textures/pencil.png')
const ADD_BUTTON_TEXTURE := preload('res://assets/textures/add_icon.png')

func request_save() -> void:
	emit_signal('request_save')
