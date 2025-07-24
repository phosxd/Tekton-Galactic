extends Component
const name := 'master_script'
const delayed := true ## Determines whether or not this component should be initialized after other components.

var script_instance


func init(object) -> void:
	var script_id = self.parameters.get('id')
	if not script_id: return

	# Construct script.
	var script_resource:GDScript = SandboxManager.sandbox_get_script(script_id)
	if not script_resource: return
	script_instance = script_resource.new()

	# Initialize script.
	script_instance.init(object, self.parameters)


func tick(delta:float) -> void:
	if not script_instance: return
	script_instance.tick(delta)
