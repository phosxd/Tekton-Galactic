class_name Tile extends CollisionShape2D

const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
const default_mass:float = 100
const default_integrity:float = 0.5
const default_elasticity:float = 0.05
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Tile/default_collision_shape.tres')
const default_texture:Texture2D = preload('res://CORE/Game Objects/Tile/default_texture.tres')

var id:StringName
var components:Array[Component] = []
var mass:float
var integrity:float
var elasticity:float
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
	new_tile.shape = default_collision_shape
	new_tile.get_node('%Texture').texture = default_texture

	new_tile.ready.connect(func() -> void:
		for component:Component in new_tile.components:
			component.init(new_tile) # Assign component instance to this tile.
	)
	return new_tile
	


func _ready() -> void:
	for component:Component in self.components:
		component.init(self)


func get_grid():
	var parent = $'../'
	return parent if parent is Grid else null


func get_neighbors() -> Array[Tile]:
	var result:Array[Tile] = []
	return result



func sleep() -> void:
	pass

func wake() -> void:
	pass
