class_name SandboxManager

# Paths.
const Assets_path:String = 'Assets'
const Audio_assets_path:String = Assets_path+'/Assets'
const Textures_assets_path:String = Assets_path+'/Textures'
const Game_path:String = 'Game'
const Game_tile_path:String = Game_path+'/Tile'

# Placeholder objects.
static var Placeholder_texture:Texture2D
static var Placeholder_tile:SandboxObject


# Loaded objects.
static var Tiles:Dictionary[String,SandboxObject] = {}



static func load_sandbox(root_path:String) -> void:
	# Load tiles.
	var game_tile_directory = DirAccess.open(Game_tile_path)
	for filename:String in game_tile_directory.get_files():
		if not filename.ends_with('.json'): continue
		var json_data = FileUtils.open_file_as_json(game_tile_directory+'/'+filename)
		if not json_data: continue

		var sandbox_object := SandboxObject.new(json_data)
		if not sandbox_object.valid: continue
		Tiles[sandbox_object.id] = sandbox_object 
		


static func get_texture(id:String): ## Return texture from the file name / file path (Starting from the texture assets directory). If unable to open as a texture, returns placeholder texture.
	var file = FileAccess.open(Audio_assets_path, FileAccess.READ)
	if not file: return Placeholder_texture


static func get_tile(id:String): ## Returns tile data from the tile ID. If unable to open as a `SandboxObject`, returns placeholder tile.
	return Tiles.get(id)
