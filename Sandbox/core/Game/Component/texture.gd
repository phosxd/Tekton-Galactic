extends Component
const name := 'texture'

const texture_filter_map:Dictionary[String,CanvasItem.TextureFilter] = {
	'linear': CanvasItem.TEXTURE_FILTER_LINEAR,
	'nearest': CanvasItem.TEXTURE_FILTER_NEAREST,
}


func init(object) -> void:
	# If no textures, return.
	if self.parameters.get('variants') == null:
		return
	#If `in_world_size` unspecified, set to ONE.
	self.parameters.in_world_size = self.parameters.get('in_world_size', Vector2.ONE)
	# If `clip_to_fit_shape` unspecified, set to false.
	self.parameters.clip_to_fit_shape = self.parameters.get('clip_to_fit_shape', false)
	# If `filter` unspecified, set to "nearest".
	self.parameters.filter = self.parameters.get('filter', 'nearest')

	# Randomly apply one of the textures defined in "variants".
	var random_index = randi_range(0, self.parameters.variants.size()-1)
	object.set_main_texture(
		SandboxManager.get_texture(self.parameters.variants[random_index]),
		self.parameters.in_world_size,
		self.parameters.clip_to_fit_shape,
		texture_filter_map.get(self.parameters.filter, texture_filter_map.nearest),
	)
