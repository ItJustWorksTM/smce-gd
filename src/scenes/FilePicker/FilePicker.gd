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

onready var filename_input := $VBoxContainer/HBoxContainer2/HBoxContainer2/HBoxContainer/LineEdit
onready var header_label := $VBoxContainer/HBoxContainer2/HBoxContainer2/HBoxContainer/Label

class ViewModel:
    extends ViewModelExt.WithNode

    enum Mode {
        SAVE_FILE,
        SELECT_FILE,
        SELECT_FOLDER,
        SELECT_ANY
    }
    # .new_file_name.to(obsvr("")) \
    # .new_file_valid.to(obsvr(false)) \
    func save_mode(mode): return mode == Mode.SAVE_FILE
    func items(save_mode, files, folders): return folders + (files if !save_mode else [])
    func selected_index(items, selected): return items.find(selected)
    func on_folder(folders, index): return index < folders.size() && index != -1
    func open_text(save): return "Save" if save else "Select"
    func header_text(save): return "Name" if save else "Open"
    func select_mode(save): return !save

    func open_disabled(select_mode, s, on_folder, file_valid):
        if select_mode:
            return s < 0 || s >= 0 && on_folder
        else:
            return !file_valid
    
    func pop_disabled(can_pop): return !can_pop
    func input_color(is_valid): return Color.whitesmoke if is_valid else Color.red

    func filters_index(filters, active_filter): return filters.keys().find(active_filter)
    func filters_text(filters: Dictionary):
        var ret = []
        for key in filters.keys(): ret.append("%s %s" % [key, str(filters[key])])
        return ret
    
    func _init(n).(n): pass

    func _on_init():
        bind() \
            .save_mode.dep([self.mode]) \
            .select_mode.dep([self.save_mode]) \
            .header_text.dep([self.save_mode]) \
            .open_text.dep([self.save_mode]) \
            .items.dep([self.save_mode, self.files, self.folders]) \
            .selected_index.dep([self.items, self.selected]) \
            .on_folder.dep([self.folders, self.selected_index]) \
            .open_disabled.dep([self.select_mode, self.selected_index, self.on_folder, self.new_file_valid]) \
            .pop_disabled.dep([self.can_pop]) \
            .input_color.dep([self.is_valid]) \
            .filters_text.dep([self.filters]) \
            .filters_index.dep([self.filters, self.active_filter]) \
        
        bind() \
            .open_disabled.to(node.open_button, "disabled") \
            .open_text.to(node.open_button, "text") \
            .pop_disabled.to(node.up_btn, "disabled") \
            .input_color.to(node.edit, "custom_colors/font_color") \
            .full_path.to(self, "_update_path_edit") \
            .header_text.to(node.header_label, "text") \
            .save_mode.to(node.filename_input, "visible") \
            .select_mode.to(node.filter_dropdown, "visible") \
            .new_file_name.to(self, "new_file_name")

        invoke() \
            ._try_path_change.on(node.edit, "text_changed") \
            ._try_filename_change.on(node.filename_input, "text_changed") \
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

    func _try_filename_change(text):
        self.set_new_file_name.invoke([text])
    
    func sync_new_filename(text):
        node.edit.text = ""
        node.edit.append_at_cursor(text)

    func _on_set_filter(i):
        self.set_active_filter.invoke([self.filters.value.keys()[i]])

    func _on_dir_create():
        _actions.create_dir.invoke()
        _on_surface_pressed()

    func _update_path_edit(path):
        node.edit.text = ""
        node.edit.append_at_cursor(path)

    func _on_item_selected(index):
        if index != null:
            _actions.open.invoke()

    func _try_path_change(text):
        _actions.set_full_path.invoke([text])
    
    func _open_pressed():
        var ret = self.selected_path.value
        if self.save_mode.value:
            ret = ret.plus_file(self.new_file_name.value)
        self.on_open.invoke([ret])
    
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
    var fsf = ReactiveFsTraverser.new()
    
    fsf.set_filters.invoke([{ "Any": ["*"], "Arduino": ["*.ino", "*.pde"], "C++": ["*.cpp", "*.hpp", "*.hxx", "*.cxx"] }])
    fsf.set_active_filter.invoke(["Any"])

    var act = ActionSignal.new()
    var mode = Observable.new(ViewModel.Mode.SAVE_FILE)

    self.init_model() \
        .props() \
            .from_dict(fsf.props()) \
            .mode.to(mode) \
        .actions() \
            .from_dict(fsf.actions()) \
            .on_open.to(act) \
        .init()

    var flip = true
    while true:
        print(yield(act, "invoked"))

        var twe = Animations.anim_open(self)
        twe.start()

        yield(twe, "tween_all_completed")

        # yield(get_tree().create_timer(4), "timeout")

        mode.value = ViewModel.Mode.SELECT_FILE if flip else ViewModel.Mode.SAVE_FILE
        flip = !flip

        twe = Animations.anim_close(self)
        twe.start()

        yield(twe, "tween_all_completed")

        # queue_free()

# warning-ignore-all:return_value_discarded
