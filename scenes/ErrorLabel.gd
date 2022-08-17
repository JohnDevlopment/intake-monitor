extends Label

func _ready() -> void:
	text = ''

func set_error(e: String, time: float = -1) -> void:
	text = e
	$Timer.start(time)

func _on_Timer_timeout() -> void:
	text = ''
