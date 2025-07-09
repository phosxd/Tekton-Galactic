extends EntityComponent
const name := '2d_movement'

var valid:bool
var entity:Entity
var controller:String
var speed:float
var rotational_speed:float

var time:float
var recent_inputs:Dictionary[String,float] = {} ## All recent inputs and when they were received.


func init(entity:Entity) -> void: ## Initialize the component on the entity.
	self.entity = entity
	self.controller = self.parameters.get('controller')
	self.speed = self.parameters.get('speed')
	self.rotational_speed = self.parameters.get('rotational_speed')
	if self.controller == null || self.speed == null || self.rotational_speed == null:
		self.valid = false
		return
	self.valid = true


func tick(delta:float) -> void: ## Runs every entity tick.
	if not valid: return
	time += delta
	if self.controller == 'user':
		if not Input.is_action_pressed('shift'):

			if Input.is_action_pressed("move_up_dynamic"):
				self.move(Vector2(0, -1))
				recent_inputs['move_up_dynamic'] = time

			if Input.is_action_pressed("move_down_dynamic"):
				self.move(Vector2(0, 1))
				recent_inputs['move_right_dynamic'] = time

			if Input.is_action_pressed("move_left_dynamic"):
				self.move(Vector2(-1, 0))
				recent_inputs['move_left_dynamic'] = time

			if Input.is_action_pressed("move_right_dynamic"):
				self.move(Vector2(1, 0))
				recent_inputs['move_right_dynamic'] = time

		else:
			# Reset rotation when double clicking shift.
			if time-recent_inputs.get('shift',0) < 0.15 && time-recent_inputs.get('shift',0) > 0.01:
				self.rotate(0, true)

			elif Input.is_action_pressed('move_left_dynamic'):
				self.rotate(-1)
				recent_inputs['move_right_dynamic'] = time

			elif Input.is_action_pressed('move_right_dynamic'):
				self.rotate(1)
				recent_inputs['move_right_dynamic'] = time

			recent_inputs['shift'] = time


func move(direction:Vector2) -> void: ## Adds velocity to the Parent based on the given direction & the component's `Speed` attribute.
	self.entity.apply_force(Vector2(direction.x, direction.y) * self.speed)

func rotate(angle:float, set:bool=false) -> void:
	if set:
		self.entity.angular_velocity = angle
		return
	self.entity.apply_torque(angle*self.rotational_speed)
