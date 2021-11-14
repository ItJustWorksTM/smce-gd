#
#  FilePicker.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name FilePicker
extends PanelContainer

var model: ViewModel

onready var edit = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TextEdit
onready var up_btn = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Button
onready var item_list = $VBoxContainer/PanelContainer/VBoxContainer/ItemList
onready var open_button = $VBoxContainer/HBoxContainer2/Button
onready var filter_dropdown := $VBoxContainer/PanelContainer/VBoxContainer/OptionButton

onready var create_btn := $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Button3
onready var folder_create_surface := $FolderCreate
onready var create_dir_popup := $FolderCreate/CreateDirPopUp

class ViewModel:
    extends ViewModelExt.WithNode

    func open_disabled(s, on_folder): return s < 0 || s >= 0 && on_folder
    func pop_disabled(can_pop): return !can_pop
    func input_color(is_valid): return Color.whitesmoke if is_valid else Color.red
    func items(files, folders): return folders + files
    func selected_index(items, selected): return items.find(selected)
    func on_folder(folders, index): return index < folders.size() && index != -1

    func filters_index(filters, active_filter): return filters.keys().find(active_filter)
    func filters_text(filters: Dictionary):
        var ret = []
        for key in filters.keys(): ret.append("%s %s" % [key, str(filters[key])])
        return ret
    
    func _init(n).(n): pass

    func _on_init():
        bind() \
            .items.dep([self.files, self.folders]) \
            .selected_index.dep([self.items, self.selected]) \
            .on_folder.dep([self.folders, self.selected_index]) \
            .open_disabled.dep([self.selected_index, self.on_folder]) \
            .pop_disabled.dep([self.can_pop]) \
            .input_color.dep([self.is_valid]) \
            .filters_text.dep([self.filters]) \
            .filters_index.dep([self.filters, self.active_filter]) \
        
        bind() \
            .open_disabled.to(node.open_button, "disabled") \
            .pop_disabled.to(node.up_btn, "disabled") \
            .input_color.to(node.edit, "custom_colors/font_color") \
            .full_path.to(self, "_update_file_list") \

        invoke() \
            ._try_path_change.on(node.edit, "text_changed") \
            ._open_pressed.on(node.open_button, "pressed") \
            ._on_create_btn_toggled.on(node.create_btn, "toggled") \
            ._on_surface_pressed.on(node.folder_create_surface, "pressed") \
            .pop.on(node.up_btn, "pressed") \

        # Initialize children
        node.item_list.init_model() \
            .props() \
                .items.to(self.items) \
                .selected.to(self.selected_index) \
            .actions() \
                .set_selected.to(self._set_selected) \
                .activate.to(self.open) \
            .init()

        node.filter_dropdown.init_model() \
            .props() \
                .items.to(self.filters_text) \
                .selected.to(self.filters_index) \
            .actions() \
                .set_selected.to(self._on_set_filter) \
            .init() 

        node.create_dir_popup.init_model() \
            .props() \
                .text_prop.to(self.new_dir_name) \
                .can_create.to(self.new_dir_valid) \
            .actions() \
                .set_text.to(self.set_new_dir_name) \
                .on_create.to(self._on_dir_create) \
            .init()

    func _on_set_filter(i):
        self.set_active_filter.invoke([self.filters.value.keys()[i]])

    func _on_dir_create():
        _actions.create_dir.invoke()
        _on_surface_pressed()

    func _update_file_list(path):
        node.edit.text = ""
        node.edit.append_at_cursor(path)

    func _on_item_selected(index):
        if index != null:
            _actions.open.invoke()

    func _try_path_change(text):
        _actions.set_full_path.invoke([text])
    
    func _open_pressed():
        self.on_open.invoke([self.selected_path.value])
    
    func _set_selected(index):
        _actions.select.invoke([_props.items.value[index]])

    func _on_create_btn_toggled(toggled):
        node.folder_create_surface.disabled = !toggled
        if !toggled:
            Animations.anim_open(node.create_dir_popup).start()
        else:
            Animations.anim_close(node.create_dir_popup).start()
            node.create_dir_popup.line_edit.grab_focus()
    
    func _on_surface_pressed():
        node.create_btn.pressed = false
        _on_create_btn_toggled(false)


func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():
    self.rect_pivot_offset = self.rect_size / 2
    var fsf = FsTraverserMiddleMan.new()
    fsf._actions.set_filters.invoke([{ "Any": ["*"], "Arduino": ["*.ino", "*.pde"], "C++": ["*.cpp", "*.hpp", "*.hxx", "*.cxx"] }])
    fsf._actions.set_active_filter.invoke(["Any"])

    var act = ActionSignal.new()

    self.init_model() \
        .props() \
            .from_dict(fsf.props()) \
        .actions() \
            .from_dict(fsf.actions()) \
            .on_open.to(act) \
        .init()

    while true:
        print(yield(act, "invoked"))

        var twe = Animations.anim_open(self)
        twe.start()

        yield(twe, "tween_all_completed")

        # yield(get_tree().create_timer(4), "timeout")

        twe = Animations.anim_close(self)
        twe.start()

        yield(twe, "tween_all_completed")

        # queue_free()

# warning-ignore-all:return_value_discarded
