extends Component
const name := 'collision_shape'


func init(object) -> void:
	# If no id, return.
	if self.parameters.get('id') == null: return
	# Apply the collision shape
	var shape = SandboxManager.get_shape(self.parameters.id)
	if not shape: return
	object.set_general_shape(shape)
