extends Node

func make_runner() -> BoardRunner:
	var runner = BoardRunner.new()
	add_child(runner)
	return runner

