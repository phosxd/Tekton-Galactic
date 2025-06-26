extends EntityComponent
const name := 'user_controlled'

var _Parent:Entity


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	_Parent = entity
	
