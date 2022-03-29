class_name BetterOptionButton
extends OptionButton

var options: Array: 
    get = get_options,
    set = set_options

func get_options() -> Array:
    var ret = []
    for i in self.item_count:
        ret.append(self.get_item_text(i))
        
    return ret

func set_options(v: Array):
    self.clear()
    
    for va in v:
        self.add_item(va)
    
