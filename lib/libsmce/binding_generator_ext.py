from binding_generator import *
import json

def find_bases(heap, initial):

    ret = []

    buf = initial
    buf2 = []

    while len(buf) > 0:
        for cl in heap:
            if cl["name"] in buf:
                ret.append(cl)
                print(cl["name"])
                
                if "inherits" in cl:
                    buf2.append(cl["inherits"])
        buf = buf2
        buf2 = []
    
    return ret

def generate_bindings(path, needed_classes, use_template_get_node):
    classes = json.load(open(path))

    classes["classes"] = find_bases(classes["classes"], needed_classes)

    target_dir = "."

    generate_global_constants(classes, target_dir)
    generate_global_constant_binds(classes, target_dir)
    generate_builtin_bindings(classes, target_dir, "float_64")
    generate_engine_classes_bindings(classes, target_dir, use_template_get_node)
    generate_utility_functions(classes, target_dir)
