var Audio_assets:Dictionary[String,Resource]
var Texture_assets:Dictionary[String,Resource]

func load_sandbox(root_path:String) -> void:
	var root_directory = DirAccess.open(root_path)
	for path:String in root_directory.get_files():
		pass
