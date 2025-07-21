## Entity Component for implementing 2D directional & rotational movement.
extends EntityComponent
const name := '2d_movement'

var valid:bool
var entity:Entity
var controller:String
var maximum_directional_force:float
var maximum_rotational_force:float


func init(object:Entity) -> void: ## Initialize the component on the entity.
	self.entity = object
	self.controller = self.parameters.get('controller')
	self.maximum_directional_force = self.parameters.get('maximum_directional_force')
	self.maximum_rotational_force = self.parameters.get('maximum_rotational_force')
	if self.controller == null || self.maximum_directional_force == null || self.maximum_rotational_force == null:
		self.valid = false
		return
	self.valid = true


func tick(_delta:float) -> void: ## Runs every entity tick.
	if not valid: return
	if self.controller == 'user':
		# Rotational movement.
		if Input.is_action_pressed('shift'):
			if Input.is_action_pressed('move_left'):
				self.rotate(-1, Input.get_action_strength('move_left'))
			elif Input.is_action_pressed('move_right'):
				self.rotate(1, Input.get_action_strength('move_right'))
		# Directional movement.
		else:
			if Input.is_action_pressed("move_up"):
				self.move(Vector2.UP.rotated(self.entity.rotation), Input.get_action_strength('move_up'))
			if Input.is_action_pressed("move_down"):
				self.move(Vector2.DOWN.rotated(self.entity.rotation), Input.get_action_strength('move_down'))
			if Input.is_action_pressed("move_left"):
				self.move(Vector2.LEFT.rotated(self.entity.rotation), Input.get_action_strength('move_left'))
			if Input.is_action_pressed("move_right"):
				self.move(Vector2.RIGHT.rotated(self.entity.rotation), Input.get_action_strength('move_right'))


func move(direction:Vector2, strength:float) -> void: ## Adds velocity to the Parent based on the given direction & the component's `Speed` attribute.
	self.entity.apply_force((Vector2(direction.x, direction.y) * self.maximum_directional_force) * strength)


func rotate(angle:float, strength:float, set_value:bool=false) -> void:
	if set_value:
		self.entity.angular_velocity = angle
		return
	self.entity.apply_torque((angle*self.maximum_rotational_force) * strength)
