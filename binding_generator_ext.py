from binding_generator import *
import json

def generate_bindings(path, needed_classes, use_template_get_node):
    global classes
    classes = json.load(open(path))

    icalls = set()

    needed_classes = list(filter(lambda e: e["name"] in needed_classes, classes))
    generated_classes = []

    for c in needed_classes:
        if c['name'] in generated_classes:
            continue
        generated_classes.append(c['name'])

        if c['base_class'] != '' and is_class_type(c['base_class']):
            needed_classes.append(next(item for item in classes if item['name'] == c['base_class']))

        used_classes = get_used_classes(c)
        needed_classes.extend(filter(lambda e: (e['name'] in used_classes), classes))

        if use_template_get_node and c["name"] == "Node":
            correct_method_name(c["methods"])

        header = generate_class_header(used_classes, c, use_template_get_node)

        impl = generate_class_implementation(icalls, used_classes, c, use_template_get_node)

        header_file = open("include/gen/" + strip_name(c["name"]) + ".hpp", "w+")
        header_file.write(header)

        source_file = open("src/gen/" + strip_name(c["name"]) + ".cpp", "w+")
        source_file.write(impl)

    generated_classes = list(filter(lambda e: e["name"] in generated_classes, classes))

    icall_header_file = open("include/gen/__icalls.hpp", "w+")
    icall_header_file.write(generate_icall_header(icalls))

    register_types_file = open("src/gen/__register_types.cpp", "w+")
    register_types_file.write(generate_type_registry(generated_classes))

    init_method_bindings_file = open("src/gen/__init_method_bindings.cpp", "w+")
    init_method_bindings_file.write(generate_init_method_bindings(generated_classes))
