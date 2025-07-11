class_name Tile extends CollisionShape2D

const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
const default_mass:float = 100
const default_integrity:float = 0.5
const default_elasticity:float = 0.05
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Tile/default_collision_shape.tres')
const default_texture:Texture2D = preload('res://CORE/Game Objects/Tile/default_texture.tres')

signal tile_update

var id:StringName ## Tile's type ID.
var components:Array[Component] = [] ## Tile's components.
var mass:float ## Tile's mass.
var integrity:float ## Tile's integrity.
var elasticity:float ## Tile's elasticity. Non-functional at the moment.
var _disconnect_energy_threshold:float
var _destruction_energy_threshold:float


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


# Methods.
# --------
func get_grid():
	var parent = $'../'
	return parent if parent is Grid else null


func get_tile_from_offset(offset:Vector2i): ## Gets a tile from the parent `grid` using this `tile`'s position and the offset.
	var grid = self.get_grid()
	if not grid: return null
	return grid.get_tile(Vector2i(self.position)+offset)


func get_neighbors() -> Array[Tile]:
	var tiles:Array[Tile] = []
	var left = get_tile_from_offset(Vector2i.LEFT)
	var right = get_tile_from_offset(Vector2i.RIGHT)
	var up = get_tile_from_offset(Vector2i.UP)
	var down = get_tile_from_offset(Vector2i.DOWN)
	if left: tiles.append(left)
	if right: tiles.append(right)
	if up: tiles.append(up)
	if down: tiles.append(down)
	return tiles


func sleep() -> void:
	pass

func wake() -> void:
	pass



# Internal utility.
# -----------------



# Callbacks.
# ----------
