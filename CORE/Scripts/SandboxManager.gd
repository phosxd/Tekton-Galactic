
# Paths.
const Assets_path:String = 'Assets'
const Audio_assets_path:String = Assets_path+'/Assets'
const Textures_assets_path:String = Assets_path+'/Textures'

# 
static var Placeholder_texture:Texture2D


static func load_sandbox(root_path:String) -> void:
	var root_directory = DirAccess.open(root_path)


static func get_texture(id:String): ## Return texture from the file name / file path (Starting from the texture assets directory). If unable to open as a texture, returns placeholder texture.
	var file = FileAccess.open(Audio_assets_path, FileAccess.READ)
	if not file: return Placeholder_texture
