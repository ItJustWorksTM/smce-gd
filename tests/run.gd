extends SceneTree

func _init():
	var exit_code = yield(run_tests(), "completed")
	if exit_code == null:
		exit_code = 1
	quit(exit_code)

func run_tests():
	yield(self, "idle_frame")
	
	var tests = discover_tests()
	
	print("running tests")
	print()
	
	var exit_code = 0
	
	for test in tests:
		for method in test.methods:
			print("test %s::%s => " % [test.path, method])
			
			var time_start = OS.get_ticks_msec()
			var res = test.object.call(method)
			var time_end = OS.get_ticks_msec()
			
			if res is GDScriptFunctionState:
				res = yield(res, "completed")
			
			var elapsed = time_end - time_start
			print(res, " ~ (Took %dms)" % elapsed if elapsed > 0 else "")
			
			if res.is_err():
				exit_code = 1
			
			print()
			
	print("Done.")
	
	return exit_code

class Test:
	var path
	var object
	var methods
	
	func _init(path, obj, methods):
		self.path = path
		self.object = obj
		self.methods = methods

func discover_tests() -> Array:
	var scripts = Fs.list_files("res://tests")
	
	var ret := []
	for path in scripts:
		if !ResourceLoader.exists(path, "GDScript"):
			continue
		
		var script: GDScript = load(path)
		
		if script == null || script == get_script():
			continue
		
		var instance: Object = script.new()
		
		var methods = instance.get_method_list()
		
		var tests := []
		
		for method in methods:
			if method["name"].begins_with("test_"):
				tests.push_back(method["name"])
		
		if !tests.empty():
			ret.push_back(Test.new(path, instance, tests))
	
	return ret
