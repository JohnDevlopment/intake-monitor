extends 'res://addons/gut/test.gd'

func test_asserts():
	gut.p('-- testing the quality of asserts --')
	var re := RegEx.new()
	
	var result = re.compile("[0-9]+|[*/+-]")
	assert_eq(result, OK)
	
	result = re.search_all('2 * 30')
	assert_eq(result.size(), 3)
	for e in result:
		var m : RegExMatch = e
		gut.p("\t%s" % m.get_string())
	
	if is_passing():
		var m : RegExMatch = (result as Array).pop_back()
		var ms : String = m.get_string()
		for s in '*/+-':
			assert_string_does_not_contain(ms, s, false)
