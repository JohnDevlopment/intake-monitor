tool
extends LineEdit
class_name NumberEdit

const ERROR_PREFIX := 'NumberEdit: '

signal cancelled_edit()
signal edit_confirmed(new_text)

export var default_value := 0 setget set_default_value
export var cancel_on_focusout := false
export var suffix := '' setget set_suffix

var _prev_text := ''
var _expr_split_regex : RegEx
var _expr : Expression
var _lock := false
var _actual_text := ''

func _ready() -> void:
	theme_type_variation = 'NumberEdit'
	
	_expr = Expression.new()
	
	# Regular expression for entry contents
	var code := 0
	_expr_split_regex = RegEx.new()
	code = _expr_split_regex.compile("\\d+(\\.\\d+)?|[*/+-]")
	if not Engine.editor_hint:
		assert(code == OK, "failed to compile")
		pass
	
	_actual_text = str(default_value)
	_prev_text = _actual_text
	call_deferred('_update_display')
	
	connect('text_entered', self, '_on_text_entered')
	connect('focus_exited', self, '_on_focus_out')
	connect('focus_entered', self, '_on_focus_in')

func _change_or_revert_text(s: String) -> void:
	if _lock: return
	
	_lock = true
	
	if not _validate_text(s):
		_cancel()
		return
	
	var result = _expr.execute()
	if _expr.has_execute_failed():
		push_error(
			ERROR_PREFIX + \
			"Failed to execute expression: %s" % _expr.get_meta('expression')
		)
		_cancel()
		return
	
	set_value(result)
	call_deferred('_update_display')
	
	set_deferred('_lock', false)
	
	emit_signal('edit_confirmed', _actual_text)

func get_value():
	return int(_actual_text)

func set_default_value(v: int) -> void:
	default_value = v
	set_value(v)
	update()

func set_suffix(s: String) -> void:
	suffix = s
	call_deferred('_update_display')

func set_value(v) -> void:
	assert(typeof(v) in [TYPE_STRING, TYPE_INT, TYPE_REAL], "invalid type")
	match typeof(v):
		TYPE_INT:
			# Convert int to string
			_actual_text = str(v)
		TYPE_REAL:
			# Convert float to int, then int to string
			_actual_text = str(int(round(v)))
		_:
			# Is string
			_actual_text = v
	_prev_text = text
	call_deferred('_update_display')

func _cancel() -> void:
	text = _prev_text
	_lock = false
	emit_signal('cancelled_edit')

func _validate_text(s: String) -> bool:
	var result := _expr_split_regex.search_all(s)
	if result.size() == 0:
		return false
	
	if true:
		var atoms := PoolStringArray()
		
		for e in result:
			var atom := (e as RegExMatch).get_string()
			var valid := {
				f = atom.is_valid_float(),
				i = atom.is_valid_integer(),
				either = atom.is_valid_float() || atom.is_valid_integer()
			}
			if valid.either:
				# Always a valid float
				if valid.i:
					# Valid integer
					atom += ".0"
			
			atoms.push_back(atom)
		
		s = atoms.join(' ')
	
	# The string should not end with an operator
	var m : RegExMatch = result.pop_back()
	var ms : String = m.get_string()
	for c in '*/+-':
		if c in ms: return false
	
	_expr.set_meta('expression', s)
	if _expr.parse(s) != OK:
		push_error(ERROR_PREFIX + _expr.get_error_text())
		return false
	
	if OS.has_feature('debug'):
		print("s: ", s)
	
	return true

func _update_display() -> void:
	text = _actual_text
	if not suffix.empty():
		text += " %s" % suffix

# Signals

func _on_focus_out() -> void:
	if cancel_on_focusout:
		_cancel()
		return
	_change_or_revert_text(text)

func _on_focus_in() -> void:
	text = _actual_text

func _on_text_entered(new_text: String) -> void:
	_change_or_revert_text(new_text)
	release_focus()
