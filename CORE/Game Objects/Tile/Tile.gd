class_name Tile extends CollisionShape2D

const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
const default_mass:float = 100
const default_integrity:float = 0.5
const default_elasticity:float = 0.05
const default_collision_shape:Shape2D = preload('res://CORE/Game Objects/Tile/default_collision_shape.tres')
const default_texture:Texture2D = preload('res://CORE/Game Objects/Tile/default_texture.tres')

var grid_position := Vector2i() ## Used to determine the true position of the tile. `Node2D.position` is unreliable when parent Grid is moving in space.
var render_group:int
var in_world_texture_size:Vector2
var clip_texture:bool = false
var is_render_queued:bool = false

signal tile_update
signal neighbor_tile_update(direction:Vector2i)
signal before_destroyed
signal before_disconnected
signal after_destroyed
signal after_disconnected

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
	new_tile.neighbor_tile_update.connect(new_tile._neighbor_tile_update)
	new_tile.before_destroyed.connect(new_tile._before_destroyed)
	new_tile.before_disconnected.connect(new_tile._before_disconnected)
	new_tile.after_destroyed.connect(new_tile._after_destroyed)
	new_tile.after_disconnected.connect(new_tile._after_disconnected)
	new_tile.get_node('%Texture Mask').draw.connect(new_tile._draw_texture_mask)

	return new_tile



func _ready() -> void:
	# Initialize components.
	for component:Component in self.components:
		component.init.call_deferred(self) # Assign component instance to this tile.
		if component.has_method('tick'):
			self.process_mode = Node.PROCESS_MODE_INHERIT


func _process(delta:float) -> void:
	# Process component ticks.
	for component in self.components:
		if component.has_method('tick'):
			component.tick.call(delta)

	# Render if queued.
	if is_render_queued:
		self.is_render_queued = false
		self.render()




# Setters.
# --------
func set_main_shape(shape:Shape2D, rotation_degrees:float=0, clip_texture:bool=false) -> void:
	if shape == self.shape && rotation_degrees == self.rotation_degrees && clip_texture == self.clip_texture: return
	self.set_shape(shape)
	self.rotation_degrees = rotation_degrees
	self.clip_texture = clip_texture
	if clip_texture && shape.get_rect().size.abs() >= %Texture.texture.get_size()*%Texture.scale:
		%'Texture Mask'.clip_children = CLIP_CHILDREN_ONLY
		%'Texture Mask'.queue_redraw()
	else:
		%'Texture Mask'.clip_children = CLIP_CHILDREN_DISABLED
	self.queue_render()


func set_main_texture(texture:Texture2D=default_texture, in_world_size:Vector2=Vector2.ONE, filter:TextureFilter=TEXTURE_FILTER_NEAREST) -> void:
	if not texture: return
	if texture == %Texture.texture && in_world_size == self.in_world_texture_size && filter == %Texture.texture_filter: return
	%Texture.texture = texture
	%Texture.texture_filter = filter
	%Texture.scale = Vector2(in_world_size/texture.get_size())
	self.in_world_texture_size = in_world_size
	if self.clip_texture && self.shape.get_rect().size.abs() >= %Texture.texture.get_size()*%Texture.scale:
		%'Texture Mask'.clip_children = CLIP_CHILDREN_ONLY
		%'Texture Mask'.queue_redraw()
	else:
		%'Texture Mask'.clip_children = CLIP_CHILDREN_DISABLED
	self.queue_render()




# Methods.
# --------
func get_grid():
	var parent = self.get_parent()
	return parent if parent is Grid else null


func render() -> void: ## Attempts to render the tile as an TileMMI instance.
	self.render_group = hash(%Texture.texture)+hash(%Texture.texture_filter)
	self.get_grid().remove_instance_from_mmi(self.render_group, self.grid_position)
	if self.clip_children:
		%'Texture Mask'.visible = true
		return
	%'Texture Mask'.visible = false # This will make both the texture & the texture mask invisible.
	self.get_grid().add_instance_to_mmi(
		self.render_group,
		%Texture.texture,
		%Texture.texture_filter,
		Transform2D(self.rotation+%Texture.rotation, self.scale*%Texture.scale, self.skew+%Texture.skew, self.grid_position),
	)


func queue_render() -> void:
	self.is_render_queued = true


func get_texture_node() -> Sprite2D:
	return %Texture


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
		'top_left': self.get_tile_from_offset(Vector2i.UP+Vector2i.LEFT),
		'top_right': self.get_tile_from_offset(Vector2i.UP+Vector2i.RIGHT),
		'bottom_left': self.get_tile_from_offset(Vector2i.DOWN+Vector2i.LEFT),
		'bottom_right': self.get_tile_from_offset(Vector2i.DOWN+Vector2i.RIGHT),
	}
	return tiles


func start_hovering_tile() -> void: ## Let the tile know it is being hovered over by the cursor.
	return
	var new_material = ShaderMaterial.new()
	new_material.shader = SandboxManager.get_shader('tile_highlight')
	for neighbor:Tile in self.get_neighbors().values():
		if not neighbor: continue
		neighbor.get_texture_node().material = new_material
		neighbor.get_texture_node().modulate = Color.RED
	self.get_texture_node().material = new_material


func stop_hovering_tile() -> void: ## Let the tile know it is no longer being hovered over by the cursor.
	return
	for neighbor:Tile in self.get_neighbors().values():
		if not neighbor: continue
		neighbor.get_texture_node().material = null
		neighbor.get_texture_node().modulate = Color.WHITE
	self.get_texture_node().material = null


func sleep() -> void:
	pass

func wake() -> void:
	pass



# Internal.
# ---------
func _draw_texture_mask() -> void:
	if not self.clip_texture: return
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
func _before_destroyed() -> void:
	self.get_grid().remove_instance_from_mmi(self.render_group, self.grid_position)


func _before_disconnected() -> void:
	self.get_grid().remove_instance_from_mmi(self.render_group, self.grid_position)


func _after_destroyed() -> void:
	pass


func _after_disconnected() -> void:
	self.queue_render()


func _tile_update() -> void:
	self._emit_neighbor_updates()


func _neighbor_tile_update(direction:Vector2i) -> void:
	pass
