extends Component
const name := 'texture'


func init(object) -> void:
	# If no textures, return.
	if self.parameters.get('variants') == null:
		return
	# Randomly apply one of the textures.
	var random_index = randi_range(0, self.parameters.variants.size()-1)
	object.get_node('Texture').texture = SandboxManager.get_texture(self.parameters.variants[random_index])
