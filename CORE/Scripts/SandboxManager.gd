extends Node

# Paths.
const Sandbox_path:String = 'res://Sandbox'
const Assets_path:String = 'Assets'
const Audio_assets_path:String = Assets_path+'/Assets'
const Texture_assets_path:String = Assets_path+'/Texture'
const Shader_assets_path:String = Assets_path+'/Shader'
const Shape_assets_path:String = Assets_path+'/Shape'
const Game_path:String = 'Game'
const Game_tile_path:String = Game_path+'/Tile'
const Game_entity_path:String = Game_path+'/Entity'
const Game_generator_path:String = Game_path+'/Generator'
const Game_component_path:String = Game_path+'/Component'
const Game_tile_component_path:String = Game_component_path+'/Tile'
const Game_entity_component_path:String = Game_component_path+'/Entity'
const Game_generator_component_path:String = Game_component_path+'/Generator'

# Placeholder objects.
var Placeholder_texture:Texture2D
var Placeholder_shader:Shader
var Placeholder_shape:Shape2D
var Placeholder_tile:SandboxObject


# Indexed objects.
var textures:Dictionary[String,Texture2D] = {}
var shaders:Dictionary[String,Shader] = {}
var shapes:Dictionary[String,Shape2D] = {}
var tiles:Dictionary[String,SandboxObject] = {}
var entities:Dictionary[String,SandboxObject] = {}
var generators:Dictionary[String,SandboxObject] = {}
var components:Dictionary[String,GDScript] = {}
var tile_components:Dictionary[String,GDScript] = {}
var entity_components:Dictionary[String,GDScript] = {}
var generator_components:Dictionary[String,GDScript] = {}



func _ready() -> void:
	Placeholder_texture = PlaceholderTexture2D.new()
	Placeholder_shader = Shader.new()
	Placeholder_shader.code = 'shader_type CanvasItem;'
	Placeholder_shape = RectangleShape2D.new()
	Placeholder_shape.size = Vector2(1,1)
	load_sandbox(Sandbox_path+'/core')




func load_sandbox(root_path:String) -> void:
	# Load textures.
	var texture_directory = DirAccess.open(root_path+'/'+Texture_assets_path)
	for filename:String in texture_directory.get_files():
		if not filename.ends_with('.png') && not filename.ends_with('.tres'): continue
		var resource = load(root_path+'/'+Texture_assets_path+'/'+filename)
		if not resource: continue
		if resource is not Texture2D: continue
		self.textures[TextUtils.remove_file_extension(filename)] = resource 

	# Load shaders.
	var shader_directory = DirAccess.open(root_path+'/'+Shader_assets_path)
	for filename:String in shader_directory.get_files():
		if not filename.ends_with('.gdshader'): continue
		var resource = load(root_path+'/'+Shader_assets_path+'/'+filename)
		if not resource: continue
		if resource is not Shader: continue
		self.shaders[TextUtils.remove_file_extension(filename)] = resource 

	# Load shapes.
	var shape_directory = DirAccess.open(root_path+'/'+Shape_assets_path)
	for filename:String in shape_directory.get_files():
		if not filename.ends_with('.tres'): continue
		var resource = load(root_path+'/'+Shape_assets_path+'/'+filename)
		if not resource: continue
		if resource is not Shape2D: continue
		self.shapes[TextUtils.remove_file_extension(filename)] = resource 

	# Load tiles.
	var game_tile_directory = DirAccess.open(root_path+'/'+Game_tile_path)
	for filename:String in game_tile_directory.get_files():
		if not filename.ends_with('.json'): continue
		var json_data = FileUtils.open_file_as_json(root_path+'/'+Game_tile_path+'/'+filename)
		if not json_data: continue

		var sandbox_object := SandboxObject.new(json_data)
		if not sandbox_object.valid: continue
		self.tiles[sandbox_object.id] = sandbox_object 

	# Load entities.
	var game_entity_directory = DirAccess.open(root_path+'/'+Game_entity_path)
	for filename:String in game_entity_directory.get_files():
		if not filename.ends_with('.json'): continue
		var json_data = FileUtils.open_file_as_json(root_path+'/'+Game_entity_path+'/'+filename)
		if not json_data: continue
		var sandbox_object := SandboxObject.new(json_data)
		if not sandbox_object.valid: continue
		self.entities[sandbox_object.id] = sandbox_object 

	# Load generators.
	var game_generator_directory = DirAccess.open(root_path+'/'+Game_generator_path)
	for filename:String in game_generator_directory.get_files():
		if not filename.ends_with('.json'): continue
		var json_data = FileUtils.open_file_as_json(root_path+'/'+Game_generator_path+'/'+filename)
		if not json_data: continue
		var sandbox_object := SandboxObject.new(json_data)
		if not sandbox_object.valid: continue
		self.generators[sandbox_object.id] = sandbox_object 

	# Load components.
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

	# Load generator components.
	var game_generator_component_directory = DirAccess.open(root_path+'/'+Game_generator_component_path)
	for filename:String in game_generator_component_directory.get_files():
		if not filename.ends_with('.gd'): continue
		var script = load(root_path+'/'+Game_generator_component_path+'/'+filename)
		self.generator_components[script.name] = script




func get_texture(id:String, default:Texture2D=Placeholder_texture): ## Return texture from the file name / file path (Starting from the texture assets directory). If unable to open as a texture, returns placeholder texture.
	var texture = self.textures.get(id)
	return texture if texture else default


func get_shader(id:String, default=null): ## Return shader from the file name / file path (Starting from the shader assets directory). If unable to open as a shader, returns placeholder shader.
	var shader = self.shaders.get(id)
	return shader if shader else default


func get_shape(id:String, default:Shape2D=Placeholder_shape):
	var shape = self.shapes.get(id)
	return shape if shape else default


func get_tile(id:String, default=null): ## Returns tile data from the tile ID. If unable to open as a `SandboxObject`, returns placeholder tile.
	var tile = self.tiles.get(id)
	return tile if tile else default


func get_entity(id:String, default=null):
	var entity = self.entities.get(id)
	return entity if entity else default
