class_name TrackedDict extends TrackedContainer

var _dict = {}

func value(): return self._dict
func size(): return self._dict.size()
func keys(): return self._dict.keys()

func change(v):
    assert(v is Dictionary)
    var deleted_keys = self.keys()
    self._dict = v
    _emit_change(SET, deleted_keys)

func change_at(at, v):
    assert(self.contains(at), "key doesn't exist")
    self._dict[at] = v
    _emit_change(MODIFIED, at)

func insert_at(at, v):
    if at in self._dict:
        return self.change_at(at, v)
    self._dict[at] = v
    _emit_change(INSERTED, at)

func remove_at(at):
    assert(at in self._dict, "key doesn't exist")
    
    self._dict.erase(at)
    _emit_change(REMOVED, at)

func clear():
    self.change({})

func contains(at): return at in self._dict

func _get_class(): return "TrackedDict"
