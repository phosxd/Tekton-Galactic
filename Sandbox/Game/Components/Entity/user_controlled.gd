class_name ComponentUserControlled extends Component
## Component for tracking user input.

const Version:String = 'indev' # Schema version this component must follow.
var _Parent:Entity


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	_Parent = entity
	
