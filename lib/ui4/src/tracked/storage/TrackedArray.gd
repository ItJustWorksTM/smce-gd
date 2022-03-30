class_name TrackedArray extends TrackedArrayBase

func _init(init = []):
    self._arr = init

func value(): return self._arr
func size(): return self._arr.size()
func keys(): return self.size()

func change_at(at, v):
    _change_at(at, v)

func insert_at(at, v):
    _insert_at(at,v)

func remove_at(at):
    self._remove_at(at)
