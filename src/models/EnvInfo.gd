class_name EnvInfo
extends ViewModelBase

var user_dir: String

func library_patches_dir(): return user_dir.plus_file("library_patches")
func smce_resources_dir(): return user_dir.plus_file("smce_resources")
func mods_dir(): return user_dir.plus_file("mods")
func profile_dir(): return user_dir.plus_file("config/profiles")

func _init(user_dir_path = OS.get_user_data_dir()):
    user_dir = user_dir_path

    self.bind() \
        .library_patches_dir.dep([]) \
        .smce_resources_dir.dep([]) \
        .mods_dir.dep([]) \
        .profile_dir.dep([])

# TODO: put in `Fs`
func repl(base, suffix: String):
    var path = "%s/%s" % [base, suffix]
    if ! Fs.mkdir(path, true):
        return null
    return path

func repl_cp(source: String, base, suffix: String):
    var path = repl(base, suffix)
    if ! Fs.cpdir(source, path):
        return null
    return path

func _to_string():
    return """EnvInfo {
    user_dir: %s
    library_patches_dir: %s
    smce_resources_dir: %s
    mods_dir: %s
    profile_dir: %s
}""" % [self.user_dir,
        self.library_patches_dir,
        self.smce_resources_dir,
        self.mods_dir,
        self.profile_dir]
