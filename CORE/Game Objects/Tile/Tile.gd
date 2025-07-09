class_name Tile extends CollisionShape2D

const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
const neighbor_margin = 0.1
const default_mass:float = 100
const default_integrity:float = 0.5
const default_elasticity:float = 0.05
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Tile/default_collision_shape.tres')
const default_texture:Texture2D = preload('res://CORE/Game Objects/Tile/default_texture.tres')

var id:StringName ## Tile's type ID.
var components:Array[Component] = [] ## Tile's components.
var mass:float ## Tile's mass.
var integrity:float ## Tile's integrity.
var elasticity:float ## Tile's elasticity. Non-functional at the moment.
var _disconnect_energy_threshold:float
var _destruction_energy_threshold:float
var neighbors:Array[Tile] = [] ## Should not be used. Call `get_neighbors` instead.


var callback_can_disconnect = func(energy:float) -> bool:
	var result:bool = energy > _disconnect_energy_threshold
	return result


var callback_can_destroy = func(energy:float) -> bool:
	var result:bool = energy > _destruction_energy_threshold
	return result


static func construct(data:Dictionary) -> Tile:
	var new_tile := scene.instantiate()
	for key in data.COMPONENTS:
		var value = data.COMPONENTS[key]
		var new_component := Component.new()
		var component_script = SandboxManager.tile_components.get(key)
		if not component_script: component_script = SandboxManager.components.get(key)
		if not component_script: continue
		new_component.set_script(component_script)
		new_component.init_parameters(value)
		new_tile.components.append(new_component)

	new_tile.id = StringName(data.HEADER.id)
	new_tile.mass = data.DETAILS.mass
	new_tile.integrity = data.DETAILS.integrity
	new_tile.elasticity = data.DETAILS.elasticity
	new_tile._disconnect_energy_threshold = (new_tile.mass*new_tile.integrity)
	new_tile._destruction_energy_threshold = new_tile._disconnect_energy_threshold * 4
	new_tile.set_shape(default_collision_shape)
	new_tile.get_node('%Texture').texture = default_texture

	new_tile.ready.connect(func() -> void:
		for component:Component in new_tile.components:
			component.init(new_tile) # Assign component instance to this tile.
	)
	return new_tile


# Setters.
# --------
func set_general_shape(collision_shape:Shape2D) -> void:
	self.shape = collision_shape
	self.get_node('%Neighbor Margin/Collider').shape = _generate_neighbor_margin_shape(collision_shape)


# Methods.
# --------
func get_grid():
	var parent = $'../'
	return parent if parent is Grid else null


func get_neighbors() -> Array[Tile]:
	return neighbors


func sleep() -> void:
	pass

func wake() -> void:
	pass



# Internal utility.
# -----------------
static func _generate_neighbor_margin_shape(origin:Shape2D) -> Shape2D:
	var result:Shape2D
	if origin is RectangleShape2D:
		result = RectangleShape2D.new()
		result.size.x = origin.size.x + neighbor_margin
		result.size.y = origin.size.y + neighbor_margin
	if origin is CircleShape2D:
		result = CircleShape2D.new()
		result.radius = origin.radius + neighbor_margin
	return result



# Callbacks.
# ----------
func _on_neighbor_margin_body_shape_entered(body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
	if body != self.get_grid(): return
	if body_shape_index >= body.get_child_count(): return
	var shape = body.get_child(body_shape_index)
	if shape == self: return
	if shape is not Tile: return
	neighbors.append(shape)


func _on_neighbor_margin_body_shape_exited(body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
	if body != self.get_grid(): return
	if body_shape_index >= body.get_child_count(): return
	var shape = body.get_child(body_shape_index)
	if shape == self: return
	if shape is not Tile: return
	neighbors.erase(shape)
