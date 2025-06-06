class_name Component2DMovement extends Component
## Component for 2D movement for an Entity.
##
## Dependencies:
## - `ComponentUserControlled`

const Version:String = 'indev' # Schema version this component must follow.
var _Parent:Entity

var Controller:ComponentUserControlled


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	# Set default parameters.
	self.Parameters = {
		'speed': 1.0
	}

	_Parent = entity
	# Find and use `ComponentUserControlled` as movement controller.
	for component in entity.Components:
		if component is ComponentUserControlled:
			Controller = component


func move(direction:Vector2) -> void: ## Adds velocity to the Parent based on the given direction & the component's `Speed` attribute.
	_Parent.velocity.x += direction.x*Parameters.speed
	_Parent.velocity.y += direction.y*Parameters.speed
