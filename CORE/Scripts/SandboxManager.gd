extends Node

# Paths.
const Sandbox_path:String = 'res://Sandbox'
const Assets_path:String = 'Assets'
const Audio_assets_path:String = Assets_path+'/Assets'
const Texture_assets_path:String = Assets_path+'/Texture'
const Game_path:String = 'Game'
const Game_tile_path:String = Game_path+'/Tile'
const Game_component_path:String = Game_path+'/Component'
const Game_tile_component_path:String = Game_component_path+'/Tile'
const Game_entity_component_path:String = Game_component_path+'/Entity'

# Placeholder objects.
var Placeholder_texture:Texture2D
var Placeholder_tile:SandboxObject


# Loaded objects.
var tiles:Dictionary[String,SandboxObject] = {}
var components:Dictionary[String,GDScript] = {}
var tile_components:Dictionary[String,GDScript] = {}
var entity_components:Dictionary[String,GDScript] = {}



func _ready() -> void:
	Placeholder_texture = PlaceholderTexture2D.new()
	load_sandbox(Sandbox_path)




func load_sandbox(root_path:String) -> void:
	# Load tiles.
	var game_tile_directory = DirAccess.open(root_path+'/'+Game_tile_path)
	for filename:String in game_tile_directory.get_files():
		if not filename.ends_with('.json'): continue
		var json_data = FileUtils.open_file_as_json(root_path+'/'+Game_tile_path+'/'+filename)
		if not json_data: continue

		var sandbox_object := SandboxObject.new(json_data)
		if not sandbox_object.valid: continue
		self.tiles[sandbox_object.id] = sandbox_object 

	# Load componenets.
	var game_component_directory = DirAccess.open(root_path+'/'+Game_component_path)
	for filename:String in game_component_directory.get_files():
		if not filename.ends_with('.gd'): continue
		var script = load(root_path+'/'+Game_component_path+'/'+filename)
		self.components[script.name] = script

	# Load tile components.
	var game_tile_component_directory = DirAccess.open(root_path+'/'+Game_tile_component_path)
	for filename:String in game_tile_component_directory.get_files():
		if not filename.ends_with('.gd'): continue
		var script = load(root_path+'/'+Game_tile_component_path+'/'+filename)
		self.tile_components[script.name] = script

	# Load entity components.
	var game_entity_component_directory = DirAccess.open(root_path+'/'+Game_entity_component_path)
	for filename:String in game_entity_component_directory.get_files():
		if not filename.ends_with('.gd'): continue
		var script = load(root_path+'/'+Game_entity_component_path+'/'+filename)
		self.entity_components[script.name] = script




func get_texture(id:String): ## Return texture from the file name / file path (Starting from the texture assets directory). If unable to open as a texture, returns placeholder texture.
	var texture = load(Sandbox_path+'/'+Texture_assets_path+'/'+id+'.png')
	if not texture: return Placeholder_texture
	return texture


func get_tile(id:String): ## Returns tile data from the tile ID. If unable to open as a `SandboxObject`, returns placeholder tile.
	return self.tiles.get(id)
