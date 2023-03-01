extends WindowDialog

signal new_intake(name, amount, unit)

onready var intake_name: LineEdit = $MarginContainer/VBoxContainer/Form/IntakeName
onready var intake_unit: OptionButton = $MarginContainer/VBoxContainer/Form/IntakeUnit
onready var intake_amount: SpinBox = $MarginContainer/VBoxContainer/Form/IntakeAmount
onready var error_label: Label = $MarginContainer/VBoxContainer/ErrorLabel

func _ready() -> void:
	pass

func clear_form() -> void:
	intake_name.text = ''
	intake_amount.value = 100
	intake_unit.select(1)

func _on_Cancel_pressed() -> void:
	clear_form()
	hide()

func _on_IntakeUnit_item_selected(index: int) -> void:
	intake_amount.suffix = intake_unit.get_item_text(index)

func _on_Create_pressed() -> void:
	var _name : String = intake_name.text
	if _name.empty():
		error_label.set_error("Missing name field")
		return

	var amount : String = str(intake_amount.value)
	if amount.empty():
		error_label.set_error("No amount provided")
		return
	elif not amount.is_valid_integer():
		error_label.set_error("Invalid string '%s', must be an integer" % amount)
		return

	emit_signal('new_intake', _name, amount, intake_unit.text)

	_on_Cancel_pressed()
