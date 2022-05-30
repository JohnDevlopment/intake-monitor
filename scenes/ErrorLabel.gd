extends Label

func _ready() -> void:
	text = ''

func set_error(e: String) -> void:
	text = e
	$Timer.start()

func _on_Timer_timeout() -> void:
	text = ''
