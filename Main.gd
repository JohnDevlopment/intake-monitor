extends Control

const IntakeMonitor := preload('res://scenes/IntakeMonitor.tscn')
const SAVE_FILE := 'user://intake.sav'
const VERSION := '0.2'

enum FileMenu {NEW_INTAKE, CLOSE_INTAKE, QUIT = 3}

func _ready() -> void:
	var menu : PopupMenu = find_node('FileMenu').get_popup()
	menu.connect('id_pressed', self, '_on_file_menu_id_clicked')
	
	if (OS.has_feature('HTML') or OS.has_feature('web')) and not OS.is_userfs_persistent():
		var errdlg = load('res://scenes/CookiesDisabled.tscn').instance()
		(errdlg as ConfirmationDialog).popup_centered()
	
	load_save()
	call_deferred('_update_menu')
	Globals.connect('request_save', self, 'save', [], CONNECT_DEFERRED)
	
	print("Intake Monitor version %s" % VERSION)

func _exit_tree() -> void:
	exit()

func clear() -> void:
	for node in $'%Intakes'.get_children():
		if node.get_meta('is_intake', false):
			node.call('clear')
	Globals.request_save()

func exit() -> void:
	if OS.has_feature('JavaScript'):
		JavaScript.eval('window.close()')
	else:
		get_tree().quit()

func load_save():
	var file := File.new()
	
	# Create a file if it does not exist
	if not file.file_exists(SAVE_FILE):
		save()
		return
	
	if file.open(SAVE_FILE, File.READ) != OK:
		push_error("Failed to open '%s'" % SAVE_FILE)
		return
	
	# Parse JSON data
	var data = JSON.parse(file.get_as_text())
	file.close()
	if data.error != OK:
		push_error("Failed to parse JSON string: %s, at %s line %d" % [data.error_string, SAVE_FILE, data.error_line])
		return
	
	# Get result, is it not an array?
	data = data.result
	if not data is Dictionary:
		push_error("JSON data should be a dictionary")
		return
	
	var ctime : Dictionary = Time.get_date_dict_from_unix_time(data.current_date)
	var label : Label = $'%DateLabel'
	label.text = "Date: %02d/%02d/%d" % [ctime.month, ctime.day, ctime.year]
	if _is_tomorrow(Time.get_datetime_dict_from_system(), ctime):
		call_deferred('clear')
	
	$PanelContainer/VBoxContainer/Intakes/Information.deserialize(data['information'])
	
	# Create an intake for each element of the array
	for intake_data in data['intakes']:
		var intake = IntakeMonitor.instance()
		intake.deserialize(intake_data)
		$PanelContainer/VBoxContainer/Intakes.add_child(intake)
	
	if OS.has_feature('debug'):
		print('loaded file')

func save():
	var intakes := []
	var information := []
	
	if OS.has_feature('debug'):
		print('saving file')
	
	# Serialize data
	for node in $'%Intakes'.get_children():
		if node.get_meta('is_intake', false):
			intakes.push_back(node.serialize())
		elif node.get_meta('is_information', false):
			information = node.serialize()
	
	var json_data = {
		information = information,
		intakes = intakes,
		current_date = Time.get_unix_time_from_datetime_dict(
			Time.get_datetime_dict_from_system()
		)
	}
	
	json_data = JSON.print(json_data, "\t")
	var file := File.new()
	if file.open(SAVE_FILE, File.WRITE) != OK: return
	file.store_string(json_data)
	file.close()

func _date_hash(t: Dictionary) -> int:
	return (t.year << 16) | (t.month << 8) | t.day

func _is_tomorrow(a: Dictionary, b: Dictionary) -> bool:
	return _date_hash(a) > _date_hash(b)

func _update_menu():
	var file_menu = get_node('%FileMenu').get_popup()
	var ctab : int = $'%Intakes'.current_tab
	
	assert(ctab >= 0)
	file_menu.set_item_disabled(FileMenu.CLOSE_INTAKE, ctab == 0)

# Signals

func _on_file_menu_id_clicked(id: int) -> void:
	match id:
		FileMenu.NEW_INTAKE:
			$NewIntakeDialog.popup_centered()
		FileMenu.CLOSE_INTAKE:
			var tabs = $PanelContainer/VBoxContainer/Intakes
			tabs.get_child(tabs.current_tab).close()
		FileMenu.QUIT:
			call_deferred('exit')

func _on_NewIntakeDialog_new_intake(resname: String, cap: String, unit: String) -> void:
	var intake = IntakeMonitor.instance()
	intake.intake_name = resname
	intake.desired_max = int(cap)
	intake.unit = unit
	$PanelContainer/VBoxContainer/Intakes.add_child(intake)
	_update_menu()

func _on_intake_closing() -> void:
	save()
	_update_menu()

func _on_CloseButton_pressed() -> void:
	call_deferred('exit')

func _on_Intakes_tab_changed(_tab: int) -> void:
	_update_menu()
