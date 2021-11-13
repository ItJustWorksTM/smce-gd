class_name InvokeMap

class InvokeMapExt:
    var _vm

    var _property
    func _init(vm, property):
        _vm = vm
        _property = property

    func on(object, method):
        _vm._vm.invoke_on(_property, object, method)
        return _vm

var _vm
func _init(vm):
    _vm = vm
    vm.unreference()

func _get(property):
    return InvokeMapExt.new(self, property)
