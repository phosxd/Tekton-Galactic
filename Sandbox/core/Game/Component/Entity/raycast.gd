## Entity Component for implementing a raycaster that can detect objects in it's path.
## The raycast target position must be set from a master script.
extends EntityComponent
const name := 'raycast'

var Ray:RayCast2D


func init(object:Entity) -> void: ## Initialize the component on the entity.
	Ray = RayCast2D.new()

	# Set basic settings.
	Ray.hit_from_inside = true
	Ray.collide_with_areas = true
	Ray.collide_with_bodies = true

	# Set position.
	var position = self.parameters.get('position', [0,0])
	if position is not Array: return
	if position.size() != 2: return
	for axis in position:
		if axis is not int && axis is not float: return
	Ray.position = Vector2(position[0], position[1])

	# Set collision layers.
	var collision_layers = self.parameters.get('collision_layers', [])
	for layer in collision_layers:
		if not layer: continue
		if layer is not String: continue
		var layer_number = Constants.collision_layers_dictionary.get(layer)
		if not layer_number: continue
		Ray.set_collision_mask_value(layer_number, true)

	object.add_child(Ray)


func get_colliding_object(): ## Returns the first object that was hit by the raycast.
	return Ray.get_collider()


func get_colliding_shape(): ## Returns the first collision shape of the colliding object that was hit by the raycast.
	var hit_object = Ray.get_collider()
	if not hit_object: return

	var shape_id = Ray.get_collider_shape()
	if shape_id > hit_object.get_shape_owners().size()-1: return
	var shape_owner_id:int = hit_object.shape_find_owner(shape_id)
	if shape_owner_id not in hit_object.get_shape_owners(): return
	var shape_owner = hit_object.shape_owner_get_owner(shape_owner_id)
	if shape_owner is not Node: return

	return shape_owner


func set_target_position(position:Vector2) -> void:
	Ray.target_position = position
