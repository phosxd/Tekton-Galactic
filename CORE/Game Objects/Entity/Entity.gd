class_name Entity extends RigidBody2D
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
	new_entity.set_main_shape(default_collision_shape)
	new_entity.set_main_texture(default_texture, Vector2(1,2))

	new_entity.get_node('%Texture Mask').draw.connect(new_entity._draw_texture_mask)

	return new_entity
	


func _ready() -> void:
	var delayed_components:Array[Component] = []
	for component:Component in self.components:
		if component.get('delayed'):
			delayed_components.append(component)
			continue
		component.init(self)
	for component:Component in delayed_components:
		component.init(self)


func _process(delta:float) -> void:
	for component in self.components:
		if component.has_method('tick'):
			component.tick.call(delta)


# Setters.
# --------
func set_main_shape(shape:Shape2D, shape_rotation_degrees:float=0) -> void:
	%'Shape'.set_shape(shape)
	%"Shape".rotation_degrees = shape_rotation_degrees


func set_main_texture(texture:Texture2D, in_world_size:Vector2=Vector2.ONE, clip_to_fit_shape:bool=false, filter:TextureFilter=TEXTURE_FILTER_NEAREST) -> void:
	if not texture: return
	%Texture.texture = texture
	%Texture.texture_filter = filter
	%Texture.scale = Vector2(in_world_size/texture.get_size())
	%'Texture Mask'.clip_children = CLIP_CHILDREN_ONLY if clip_to_fit_shape else CLIP_CHILDREN_DISABLED


# Methods.
# --------


# Internal.
# ---------
func _draw_texture_mask() -> void:
	if %Shape.shape is RectangleShape2D:
		%'Texture Mask'.draw_rect(%Shape.shape.get_rect(), Color.WHITE)
	elif %Shape.shape is CircleShape2D:
		%'Texture Mask'.draw_circle(Vector2.ZERO, %Shape.shape.radius, Color.WHITE)
	elif %Shape.shape is ConvexPolygonShape2D:
		%'Texture Mask'.draw_colored_polygon(%Shape.shape.points, Color.WHITE)
	elif %Shape.shape is ConcavePolygonShape2D:
		%'Texture Mask'.draw_colored_polygon(%Shape.shape.points, Color.WHITE)


# Callbacks.
# ----------
