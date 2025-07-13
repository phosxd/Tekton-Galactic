extends Component
const name := 'texture'


func init(object) -> void:
	# If no textures, return.
	if self.parameters.get('variants') == null:
		return
	# If `fit_shape` unspecified, set to false.
	self.parameters.fit_shape = self.parameters.get('fit_shape', false)

	# Randomly apply one of the textures.
	var random_index = randi_range(0, self.parameters.variants.size()-1)
	object.get_node('%Texture').texture = SandboxManager.get_texture(self.parameters.variants[random_index])

	if self.parameters.fit_shape == true:
		object.get_node('%Texture Clip').clip_children = 1
