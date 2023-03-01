extends WindowDialog

signal add_intake(inktname, inktamt, inktunit)

onready var intake_name: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/IntakeName
onready var intake_amount: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/IntakeAmount
onready var intake_unit: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/IntakeUnit
onready var error_label: Label = $MarginContainer/VBoxContainer/ErrorLabel

func popup_custom(size: Vector2 = Vector2()) -> void:
	popup_centered(size)
	intake_name.grab_focus()

func set_error(msg: String, time: float = -1) -> void:
	error_label.text = msg
	$MarginContainer/VBoxContainer/ErrorLabel/Timer.start(time)

func _on_error_timeout() -> void:
	error_label.text = ''

func _on_OK_pressed() -> void:
	var inktname : String = intake_name.text
	if inktname.empty():
		set_error("No intake name provided")
		return

	var inktamt : int
	if not intake_amount.text.is_valid_integer():
		set_error("Intake amount is not a valid integer")
		return
	inktamt = int(intake_amount.text)

	# Hide the dialog when idle
	call_deferred('_on_Cancel_pressed')

	emit_signal('add_intake', inktname, inktamt, intake_unit.text)

func _on_Cancel_pressed() -> void:
	hide()
	for le in [intake_name, intake_amount]:
		le.text = ''
	intake_unit.select(0)
