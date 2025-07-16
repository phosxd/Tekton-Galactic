class_name Tile extends CollisionShape2D

const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
const default_mass:float = 100
const default_integrity:float = 0.5
const default_elasticity:float = 0.05
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Tile/default_collision_shape.tres')
const default_texture:Texture2D = preload('res://CORE/Game Objects/Tile/default_texture.tres')

signal tile_update
signal neighbor_tile_update(direction:Vector2i)
signal destroyed
signal disconnected

var id:StringName ## Tile's type ID.
var components:Array[Component] = [] ## Tile's components.
var mass:float ## Tile's mass.
var integrity:float ## Tile's integrity.
var elasticity:float ## Tile's elasticity. Non-functional at the moment.
var _disconnect_energy_threshold:float
var _destruction_energy_threshold:float


var can_disconnect = func(energy:float) -> bool:
	var result:bool = energy > _disconnect_energy_threshold
	return result


var can_destroy = func(energy:float) -> bool:
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
	new_tile.set_main_texture()

	new_tile.tile_update.connect(new_tile._tile_update)
	new_tile.destroyed.connect(new_tile._destroyed)
	new_tile.disconnected.connect(new_tile._disconnected)
	new_tile.get_node('%Texture Mask').draw.connect(new_tile._draw_texture_mask)
	return new_tile



func _ready() -> void:
	for component:Component in self.components:
		component.init.call_deferred(self) # Assign component instance to this tile.
	self.tile_update.emit.call_deferred()




# Setters.
# --------
func set_main_shape(shape:Shape2D, rotation_degrees:float=0) -> void:
	if shape == self.shape && rotation_degrees == self.rotation_degrees: return
	self.set_shape(shape)
	self.rotation_degrees = rotation_degrees
	%'Texture Mask'.queue_redraw()


func set_main_texture(texture:Texture2D=default_texture, in_world_size:Vector2=Vector2.ONE, clip_to_fit_shape:bool=false, filter:TextureFilter=TEXTURE_FILTER_NEAREST) -> void:
	if not texture: return
	%Texture.texture = texture
	%Texture.texture_filter = filter
	%Texture.scale = Vector2(in_world_size/texture.get_size())
	%'Texture Mask'.clip_children = CLIP_CHILDREN_ONLY if clip_to_fit_shape else CLIP_CHILDREN_DISABLED




# Methods.
# --------
func get_grid():
	var parent = $'../'
	return parent if parent is Grid else null


func get_texture_node() -> Sprite2D:
	return %'Texture'


func get_tile_from_offset(offset:Vector2i): ## Gets a tile from the parent `grid` using this `tile`'s position and the offset.
	var grid = self.get_grid()
	if not grid: return null
	return grid.get_tile(Vector2i(self.position)+offset)


func get_neighbors() -> Dictionary[String,Tile]:
	var tiles:Dictionary[String,Tile] = {
		'up': self.get_tile_from_offset(Vector2i.UP),
		'down': self.get_tile_from_offset(Vector2i.DOWN),
		'left': self.get_tile_from_offset(Vector2i.LEFT),
		'right': self.get_tile_from_offset(Vector2i.RIGHT),
	}
	return tiles


func start_hovering_tile() -> void: ## Let the tile know it is being hovered over by the cursor.
	var new_material = ShaderMaterial.new()
	new_material.shader = SandboxManager.get_shader('tile_highlight')
	self.get_texture_node().material = new_material


func stop_hovering_tile() -> void: ## Let the tile know it is no longer being hovered over by the cursor.
	self.get_texture_node().material = null


func sleep() -> void:
	pass

func wake() -> void:
	pass



# Internal.
# ---------
func _draw_texture_mask() -> void:
	if self.shape is RectangleShape2D:
		%'Texture Mask'.draw_rect(self.shape.get_rect(), Color.WHITE)
	elif self.shape is CircleShape2D:
		%'Texture Mask'.draw_circle(Vector2.ZERO, self.shape.radius, Color.WHITE)
	elif self.shape is ConvexPolygonShape2D:
		%'Texture Mask'.draw_colored_polygon(self.shape.points, Color.WHITE)
	elif self.shape is ConcavePolygonShape2D:
		%'Texture Mask'.draw_colored_polygon(self.shape.points, Color.WHITE)


func _emit_neighbor_updates() -> void:
	var neighbors := self.get_neighbors()
	for key in neighbors:
		var neighbor = neighbors[key]
		if not neighbor: continue
		neighbor.neighbor_tile_update.emit(Constants.directions_dictionary[key])



# Callbacks.
# ----------
func _destroyed() -> void:
	self.tile_update.emit()
	self.queue_free()


func _disconnected() -> void:
	self.tile_update.emit()


func _tile_update() -> void:
	self._emit_neighbor_updates()
