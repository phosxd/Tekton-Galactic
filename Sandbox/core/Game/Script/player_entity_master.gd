## Master script for the "player" entity.
const name := 'player_entity_master'

const max_reach := 5 ## The radius in which the player can reach.

var player_entity:Entity
var raycast_component:Component
var raycast_last_hit_tile:Tile


func init(object:Entity) -> void:
	player_entity = object
	for component:Component in player_entity.components:
		if component.name == 'raycast':
			raycast_component = component

	raycast_component.ray.draw.connect(_draw_ray)


func tick(_delta:float) -> void:
	# Get position the player is hovering over, limited with max reach.
	var grabbed_point := player_entity.get_local_mouse_position() ## The position the player is currently hovering over.
	grabbed_point = grabbed_point.normalized() * max_reach
	

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


# Callbacks.
func _draw_ray() -> void:
	raycast_component.ray.draw_line(raycast_component.ray.position, raycast_component.ray.target_position, Color.WHITE, 0.1, true)
