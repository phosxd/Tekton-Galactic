extends Node

const blueprints_path:String = 'res://CORE/Assets/Blueprints'


func _ready() -> void:
	for filename:String in DirAccess.open(blueprints_path).get_files():
		BlueprintManager.add_blueprint_from_file(filename.trim_suffix('.json'), blueprints_path+'/'+filename)
