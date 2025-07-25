## Master script for the "player" entity.
const name := 'player_entity_master'

var parameters:Dictionary = {}
var max_reach:float = 5 ## The radius in which the player can reach. Use "set_max_reach" to set.

var player_entity:Entity
var raycast_component:Component
var raycast_last_hit_tile:Tile
var grabbed_point:Vector2




func init(object:Entity, parameters:Dictionary) -> void:
	self.player_entity = object
	self.parameters = parameters

	self.set_max_reach(parameters.get('max_reach',self.max_reach))


	for component:Component in player_entity.components:
		if component.name == 'raycast':
			raycast_component = component

	raycast_component.ray.draw.connect(_draw_ray)


func tick(_delta:float) -> void:
	# Get position the player is hovering over, limited with max reach.
	grabbed_point = player_entity.get_local_mouse_position()
	grabbed_point = grabbed_point.normalized() * MathUtils.circular_clamp(grabbed_point, max_reach).length() # Limit reach to a circular radius.

	# Hover over tile using raycast component.
	raycast_component.set_target_position(grabbed_point)
	var hit_shape = raycast_component.get_colliding_shape()
	if hit_shape && hit_shape is Tile:
		# Set grabbed point to the collision point.
		grabbed_point = (raycast_component.ray.get_collision_point()-player_entity.position).rotated(-player_entity.rotation)
		# If hit a new tile, then hover it & stop hovering the previous tile.
		if not hit_shape == raycast_last_hit_tile:
			if raycast_last_hit_tile: raycast_last_hit_tile.stop_hovering_tile()
			hit_shape.start_hovering_tile()
			raycast_last_hit_tile = hit_shape
	# Stop hovering previous tile, if no tile hit.
	elif raycast_last_hit_tile:
		raycast_last_hit_tile.stop_hovering_tile()
		raycast_last_hit_tile = null

	# Process inputs.
	# --------------
	# Destroy tile.
	if Input.is_action_just_pressed('left_click') && raycast_last_hit_tile:
		raycast_last_hit_tile.get_grid().destroy_tile(raycast_last_hit_tile)
	# Clone tile.
	# Tile placing position isnt right yet, so this is disabled for now.
	#elif Input.is_action_just_pressed('right_click') && raycast_last_hit_tile:
		#var new_tile:Tile = Tile.construct(SandboxManager.get_tile(raycast_last_hit_tile.id).data)
		#var grid_position:Vector2i = Vector2i(((player_entity.position+grabbed_point).rotated(-player_entity.rotation))-raycast_last_hit_tile.get_grid().position)
		#raycast_last_hit_tile.get_grid().add_tile(new_tile, grid_position, true)

	# Queue redraws.
	raycast_component.ray.queue_redraw()




# Methods.
# --------
func set_max_reach(value:float) -> void:
	self.max_reach = value




# Callbacks.
# ----------
func _draw_ray() -> void:
	raycast_component.ray.draw_dashed_line(raycast_component.ray.position, self.grabbed_point, Color.WHITE, 0.075, 0.2, true, false)
	raycast_component.ray.draw_circle(self.grabbed_point, 0.2, Color.WHITE, false, 0.075)
