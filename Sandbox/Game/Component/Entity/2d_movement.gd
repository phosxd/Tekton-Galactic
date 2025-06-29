extends EntityComponent
const name := '2d_movement'

var valid:bool
var entity:Entity
var controller
var speed


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	self.entity = entity
	self.controller = self.parameters.get('controller')
	self.speed = self.parameters.get('speed')
	if self.controller == null || self.speed == null:
		self.valid = false
		return
	self.valid = true


func tick(_delta:float) -> void: ## Runs every entity tick.
	if not valid: return
	if controller == 'user':
		if Input.is_action_pressed("move_up_dynamic"):
			self.move(Vector2(0, -1))
		if Input.is_action_pressed("move_down_dynamic"):
			self.move(Vector2(0, 1))
		if Input.is_action_pressed("move_left_dynamic"):
			self.move(Vector2(1, 0))
		if Input.is_action_pressed("move_right_dynamic"):
			self.move(Vector2(1, 0))


func move(direction:Vector2) -> void: ## Adds velocity to the Parent based on the given direction & the component's `Speed` attribute.
	self.entity.velocity.x += direction.x*self.parameters.speed
	self.entity.velocity.y += direction.y*self.parameters.speed
