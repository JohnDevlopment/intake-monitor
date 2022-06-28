extends Node

const DELETE_BUTTON_TEXTURE := preload('res://assets/textures/delete_icon.png')
const EDIT_BUTTON_TEXTURE := preload('res://assets/textures/pencil.png')

func request_save() -> void:
	pass
	# TODO: Emit a signal which the main scene listens to, and saves the file
