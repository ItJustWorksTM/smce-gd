class_name TrackedContainer extends Tracked

# required
func value(): return []

func change_at(_at, _v):
    assert(false, "view only")

func insert_at(at, v):
    assert(false, "view only")

func remove_at(at):
    assert(false, "view only")

func clear():
    assert(false, "view only")  

func keys(): return []

func size() -> int: return 0

# provided
func value_at(at): return value()[at]

func mutate_at(at, cb):
    self.change_at(at, cb.call(self.value()[at]))

# TODO: BADD
func push(v):
    self.insert_at(self.size(), v)
        
func pop():
    self.remove_at(self.size() - 1)

func get_class(): return "TrackedContainer"
