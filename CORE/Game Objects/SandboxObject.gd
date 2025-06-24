class_name SandboxObject
## Useable objects loaded from the Sandbox.

var type:String
var id:String
var version:String
var data:Dictionary
var valid:bool = false


func _init(raw_data:Dictionary) -> void:
	var header_blueprint = BlueprintManager.get_blueprint('header')
	if not header_blueprint: return
	var header_data:Dictionary = data.get('HEADER',{})
	var matched_header:Dictionary = header_blueprint.match(header_data,{})
	if matched_header != header_data: return
	self.valid = true
