extends Component
const name := 'shape'


func init(object) -> void:
	# If no id, return.
	if self.parameters.get('normal') == null: return
	# Apply the collision shape
	var shape = SandboxManager.get_shape(self.parameters.normal)
	if not shape: return
	object.set_general_shape(shape)
