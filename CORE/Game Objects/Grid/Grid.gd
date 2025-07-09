class_name Grid extends PhysicsBody2D
const scene = preload('res://CORE/Game Objects/Grid/Grid.tscn')

signal tile_added(tile:Tile)
signal tile_removed(tile:Tile)

var partitions:Array[TilePartition] = []
var mouse_hovering:bool = false
var mouse_dragging:bool = false



static func construct() -> Grid:
	return scene.instantiate()


func _process(_delta:float) -> void:
	if mouse_hovering && Input.is_action_pressed('left_click'):
		mouse_dragging = true
	if not Input.is_action_pressed('left_click'):
		mouse_dragging = false
	if mouse_dragging:
		self.linear_velocity = -(self.get_center()-get_global_mouse_position())*2



# Utility.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass + self.position


func get_energy() -> float:
	return ((abs(self.linear_velocity.x)+abs(self.linear_velocity.y)) + abs(self.angular_velocity))


func add_tile(tile:Tile) -> void: ## Adds the given tile to the grid, and recalculates grid mass.
	if tile.get_parent() == null: self.add_child(tile)
	else: tile.reparent(self)
	_calculate_mass()


func add_tiles(tiles:Array[Tile]) -> void: ## Adds the given tiles to the grid, and recalculates grid mass. More efficient for adding multiple tiles at once.
	for tile:Tile in tiles:
		if tile.get_parent() == null: self.add_child(tile)
		else: tile.reparent(self)
	_calculate_mass()


func destroy_tile(tile:Tile) -> void: ## Destroys the given tile and recalculates grid mass.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	tile.free()
	_calculate()


func disconnect_tile(tile:Tile) -> void: ## Disconnects the given tile and recalculates grid mass.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	var new_grid := Grid.construct()
	for neighbor:Tile in tile.get_neighbors():
		new_grid.add_tile(neighbor)
	new_grid.add_tile(tile)
	self.get_parent().add_child(new_grid)

	_calculate()




# Internal Utility.
# -----------------
func _calculate_mass() -> void:
	var total_position := Vector2(0,0)
	var total_mass:float = 0
	var count:int = 0
	for child in self.get_children():
		if child is not Tile: continue
		total_position += child.position
		total_mass += child.mass
		count += 1
	if total_mass <= 0: total_mass = 0.0001
	self.center_of_mass = total_position/count
	self.mass = total_mass


func _calculate() -> void:
	# Separate all structurally disconnected sections of the Grid.
	var sections := _find_separate_sections()
	var section_index:int = -1
	for section:Array[Tile] in sections:
		section_index += 1
		if section_index == 0: continue
		var section_grid := Grid.construct()
		for section_tile:Tile in section:
			section_grid.add_tile(section_tile)
		section_grid.linear_velocity = self.linear_velocity
		section_grid.angular_velocity = self.angular_velocity
		self.get_parent().add_child(section_grid)
	
	# Recalculate mass & destroy Grid if empty.
	var tile_count:int = 0
	for child in self.get_children():
		if child is Tile: tile_count += 1
	if tile_count == 0: self.queue_free()
	else: _calculate_mass()


func _find_separate_sections() -> Array[Array]:
	var sections:Array[Array] = []
	var passed_tiles:Array[Tile] = []
	for child in self.get_children():
		if child is not Tile: continue
		if child in passed_tiles: continue
		var result := _recursive_tile_search([], child, passed_tiles)
		passed_tiles = result.passed_tiles
		if result.new_section.size() > 0: sections.append(result.new_section)

	return sections


func _recursive_tile_search(section:Array, tile:Tile, passed_tiles:Array[Tile]) -> Dictionary:
	section.append(tile)
	passed_tiles.append(tile)
	for neighbor in tile.get_neighbors():
		if not neighbor: continue
		if neighbor is not Tile: continue
		if not is_instance_valid(neighbor): continue
		if passed_tiles.has(neighbor): continue
		section.append(neighbor)
		passed_tiles.append(neighbor)
		_recursive_tile_search(section, neighbor, passed_tiles)

	return {
		'new_section': section,
		'passed_tiles': passed_tiles,
	}




func _on_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int) -> void:
	if self.get_child_count()-1 < local_shape_index: return
	if self.get_child(local_shape_index) is not Tile: return
	if body is not Grid: return
	var tile:Tile = self.get_child(local_shape_index)
	var velocity = (body.get_energy() - self.get_energy())
	var incoming_energy = abs(0.5 * (velocity))
	if tile.callback_can_destroy.call(incoming_energy):
		self.destroy_tile.call_deferred(tile)
	elif tile.callback_can_disconnect.call(incoming_energy):
		self.disconnect_tile.call_deferred(tile)


func _on_mouse_entered() -> void:
	mouse_hovering = true


func _on_mouse_exited() -> void:
	mouse_hovering = false
	if not Input.is_action_pressed('left_click'): mouse_dragging = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	match event.as_text():
		'Right Mouse Button':
			self.destroy_tile(self.get_child(shape_idx))
