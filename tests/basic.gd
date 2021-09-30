
func ok():	return Result.new().set_ok(null)

func test_sanity():
	return ok()

signal _yield
func test_yield():
	call_deferred("emit_signal", "_yield")
	yield(self, "_yield")
	return ok()
