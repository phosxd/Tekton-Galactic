extends Node

const blueprints_path:String = 'res://CORE/Assets/Blueprints'


func _ready() -> void:
	for filename:String in DirAccess.open(blueprints_path).get_files():
		BlueprintManager.add_blueprint_from_file(filename.trim_suffix('.json'), blueprints_path+'/'+filename)
	
	SandboxManager.ready.connect(func() -> void:
		var texture:Texture2D = SandboxManager.get_texture('cursor')
		DisplayServer.cursor_set_custom_image(texture, DisplayServer.CURSOR_ARROW, texture.get_size()/2)
	)
