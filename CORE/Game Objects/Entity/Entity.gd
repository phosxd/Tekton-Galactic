class_name Entity extends CharacterBody2D
## Base class for all game entities. Uses a component system to determine behavior and functionality.

const scene = preload('res://CORE/Game Objects/Entity/Entity.tscn')
const default_mass:float = 100
const default_texture:Texture2D = preload('res://CORE/Game Objects/Entity/default_texture.tres')
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Entity/default_collision_shape.tres')

var components:Array[Component] = []


static func construct(data:Dictionary) -> Entity:
	var new_entity := scene.instantiate()
	for key in data.COMPONENTS:
		var value = data.COMPONENTS[key]
		var new_component := Component.new()
		var component_script = SandboxManager.entity_components.get(key)
		if not component_script: component_script = SandboxManager.components.get(key)
		if not component_script: continue
		new_component.set_script(component_script)
		new_component.init_parameters(value)
		new_entity.components.append(new_component)

	new_entity.mass = data.DETAILS.mass
	new_entity.get_node('Collision Shape').shape = default_collision_shape
	new_entity.get_node('Texture').texture = default_texture

	new_entity.ready.connect(func() -> void:
		for component:Component in new_entity.components:
			component.init(new_entity) # Assign component instance to this tile.
	)
	return new_entity
	


func _ready() -> void:
	for component:Component in self.components:
		component.init(self)
