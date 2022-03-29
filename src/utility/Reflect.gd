class_name Reflect

static func value_compare(rhs, lhs) -> bool:
	if rhs is Array and lhs is Array:
		if rhs.size() != lhs.size(): return false
		for i in rhs.size():
			if ! value_compare(rhs[i], lhs[i]): return false
		return true
	elif rhs is Dictionary and lhs is Dictionary:
		for key in rhs:
			if ! value_compare(rhs.get(key), lhs.get(key)): return false
		return true
	elif rhs is Object and lhs is Object:
		if rhs.get_script() != lhs.get_script():
			return false
		elif rhs.has_method("eq"):
			return rhs.eq(lhs)
		else:
			return value_compare(inst2dict2(rhs), inst2dict2(lhs))
	elif typeof(rhs) == typeof(lhs):
		return rhs == lhs
	return false

static func inst2dict2(value: Object) -> Dictionary:
	var ret := {}
	for prop in get_unique_props(value):
		ret[prop] = value.get(prop)

	return ret

class _ref:
	pass
static func get_unique_props(t: Object, base = _ref.new()):
	var c = {}
	for p in t.get_property_list():
		c[p.name] = null
	
	for p in base.get_property_list():
		c.erase(p.name)
	c.erase(t.get_class())
	return c.keys()

static func stringify_struct(name, t: Object, base = RefCounted):
	var s = "%s { " % name
	for prop in get_unique_props(t, base.new()):
		if !prop.begins_with("_") && prop != "Script Variables":
			s += "%s: %s, " % [prop, t.get(prop)]
	s += "}"
	return s

static func distconnect_all(from, target: Signal):
	for connections in target.get_connections():
		if connections.callable.get_object() == from:
			target.disconnect(connections.callable)
