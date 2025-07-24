## Master script for the "player" entity.
const name := 'player_entity_master'

var player_entity:Entity
var raycast_component:Component
var raycast_last_hit_tile:Tile

var parameters:Dictionary = {}
var max_reach:float = 5 ## The radius in which the player can reach. Use "set_max_reach" to set.




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
	var grabbed_point:Vector2 = player_entity.get_local_mouse_position()
	grabbed_point = grabbed_point.normalized() * MathUtils.circular_clamp(grabbed_point, max_reach).length() # Limit reach to a circular radius.

	# Hover over tile using raycast component.
	raycast_component.set_target_position(grabbed_point)
	var hit_shape = raycast_component.get_colliding_shape()
	if hit_shape && hit_shape is Tile:
		# If hit a new tile, then hover it & stop hovering the previous tile.
		if not hit_shape == raycast_last_hit_tile:
			if raycast_last_hit_tile: raycast_last_hit_tile.stop_hovering_tile()
			hit_shape.start_hovering_tile()
			raycast_last_hit_tile = hit_shape
	# Stop hovering previous tile, if no tile hit.
	elif raycast_last_hit_tile:
		raycast_last_hit_tile.stop_hovering_tile()

	# Process inputs.
	if Input.is_action_just_pressed('right_click') && raycast_last_hit_tile:
		raycast_last_hit_tile.get_grid().destroy_tile(raycast_last_hit_tile)

	# Queue redraws.
	raycast_component.ray.queue_redraw()




# Methods.
# --------
func set_max_reach(value:float) -> void:
	self.max_reach = value




# Callbacks.
# ----------
func _draw_ray() -> void:
	raycast_component.ray.draw_dashed_line(raycast_component.ray.position, raycast_component.ray.target_position, Color.WHITE, 0.075, 0.2, true, false)
	raycast_component.ray.draw_circle(raycast_component.ray.target_position, 0.2, Color.WHITE, false, 0.075)
