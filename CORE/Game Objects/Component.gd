class_name Component
## Base class for all components. Can be applied to an Entity or Tile instance.

var parameters:Dictionary = {}


func init_parameters(parameters:Dictionary) -> void:
	# Apply parameters.
	for key in parameters:
		self.parameters[key] = parameters[key] 
