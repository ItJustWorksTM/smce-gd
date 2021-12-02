tool
class_name ImageLoader
extends ResourceFormatLoader

func get_recognized_extensions() -> PoolStringArray:
	return PoolStringArray(["png"])

func get_resource_type (path: String) -> String:
	return "ImageTexture"

func handles_type(typename: String) -> bool:
	return "Texture" == typename

func load(path, original_path):
	var image = Image.new()
	var res = image.load(path)
	if res == OK:
		var tex = ImageTexture.new()
		tex.create_from_image(image)
		return tex
	return res
