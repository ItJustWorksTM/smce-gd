class_name Dict

static func merge(lhs: Dictionary, rhs: Dictionary):
    for key in rhs.keys():
        lhs[key] = rhs[key]
    return lhs

static func subset(dict: Dictionary, keys: Array):
    var ret = {}
    for key in keys:
        ret[key] = dict[key]
    return ret