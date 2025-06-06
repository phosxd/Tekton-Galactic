class_name Component
## Base class for all components. Can be applied to an Entity or Tile instance.

var Parameters:Dictionary[String,Variant] = {}


func init_parameters(parameters:Dictionary[String,Variant]) -> void:
	# Apply parameters.
	for key in parameters:
		if typeof(Parameters[key]) != typeof(parameters[key]): continue
		Parameters[key] = parameters[key] 
