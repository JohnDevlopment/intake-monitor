extends Control

const IntakeMonitor := preload('res://scenes/IntakeMonitor.tscn')

const SAVE_FILE := 'user://intake.sav'

enum FileMenu {NEW_INTAKE, CLOSE_INTAKE, QUIT = 3}

func _ready() -> void:
	var menu : PopupMenu = find_node('FileMenu').get_popup()
	menu.connect('id_pressed', self, '_on_file_menu_id_clicked')
	
	if (OS.has_feature('HTML') or OS.has_feature('web')) and not OS.is_userfs_persistent():
		var errdlg = load('res://scenes/CookiesDisabled.tscn').instance()
		(errdlg as ConfirmationDialog).popup_centered()
	
	load_save()
	call_deferred('_update_menu')

func _exit_tree() -> void:
	exit()

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
	if not data is Array:
		push_error("JSON data should be an array")
		return
	
	# Create an intake for each element of the array
	for intake_data in data:
		var intake = IntakeMonitor.instance()
		intake.deserialize(intake_data)
		$PanelContainer/VBoxContainer/Intakes.add_child(intake)
		intake.connect('request_save', self, 'save', [], CONNECT_DEFERRED)
		intake.connect('closing', self, '_on_intake_closing', [], CONNECT_DEFERRED)

func save():
	var intakes := []
	
	for intake in $PanelContainer/VBoxContainer/Intakes.get_children():
		if intake.has_meta('is_intake'):
			intakes.push_back(intake.serialize())
	
	var json_data := JSON.print(intakes, "\t")
	var file := File.new()
	if file.open(SAVE_FILE, File.WRITE) != OK: return
	file.store_string(json_data)
	file.close()
	
	if OS.has_feature('debug'):
		print('saving file')

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
	intake.connect('request_save', self, 'save', [], CONNECT_DEFERRED)
	intake.connect('closing', self, '_on_intake_closing', [], CONNECT_DEFERRED)
	_update_menu()

func _on_intake_closing() -> void:
	save()
	_update_menu()

func _on_CloseButton_pressed() -> void:
	call_deferred('exit')

func _on_Intakes_tab_changed(_tab: int) -> void:
	_update_menu()
