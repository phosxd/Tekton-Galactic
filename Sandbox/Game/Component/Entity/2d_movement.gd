extends EntityComponent
const name := '2d_movement'

var _Parent:Entity


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	# Set default parameters.
	self.parameters = {
		'speed': 1.0
	}

	_Parent = entity


func move(direction:Vector2) -> void: ## Adds velocity to the Parent based on the given direction & the component's `Speed` attribute.
	_Parent.velocity.x += direction.x*self.parameters.speed
	_Parent.velocity.y += direction.y*self.parameters.speed
