class_name Grid extends PhysicsBody2D
const scene = preload('res://CORE/Game Objects/Grid/Grid.tscn')

signal tile_added(tile:Tile)
signal tile_removed(tile:Tile)

var tiles:Dictionary[Vector2i,Tile] = {}
var partitions:Array[TilePartition] = []



static func construct() -> Grid:
	return scene.instantiate()


func _process(_delta:float) -> void:
	pass



# Mehtods.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass + self.position


func get_energy() -> float:
	return ((abs(self.linear_velocity.x)+abs(self.linear_velocity.y)) + abs(self.angular_velocity))


func get_tile(position:Vector2i): ## Returns the tile at the given position, if doesn't exist returns null.
	var tile = self.tiles.get(position)
	if not tile: return null
	if not is_instance_valid(tile): return null
	return tile


func add_tile(tile:Tile) -> void: ## Adds the given tile to the grid, and recalculates grid mass.
	if not tile: return
	if tile.get_parent() == null: add_child(tile)
	else:
		tile.get_grid().tiles.erase(Vector2i(tile.position))
		tile.reparent(self)
	var current_tile = self.tiles.get(Vector2i(tile.position))
	if current_tile != null:
		destroy_tile(current_tile)
	self.tiles.set(Vector2i(tile.position), tile)
	self.tile_added.emit(tile)
	_calculate_mass()


func add_tiles(tiles:Array[Tile]) -> void: ## Adds the given tiles to the grid, and recalculates grid mass. More efficient for adding multiple tiles at once.
	for tile:Tile in tiles:
		if not tile: continue
		if tile.get_parent() == null: self.add_child(tile)
		else:
			tile.get_grid().tiles.erase(Vector2i(tile.position))
			tile.reparent(self)
		var current_tile = self.tiles.get(Vector2i(tile.position))
		if current_tile != null:
			destroy_tile(current_tile)
		self.tiles.set(Vector2i(tile.position), tile)
		self.tile_added.emit(tile)
	_calculate_mass()


func destroy_tile(tile:Tile) -> void: ## Destroys the given tile and recalculates grid mass.
	if not tile: return
	if not is_instance_valid(tile): return
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	self.tiles.erase(Vector2i(tile.position))
	tile.destroyed.emit()
	_calculate()


func disconnect_tile(tile:Tile) -> void: ## Disconnects the given tile and recalculates grid mass.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	var new_grid := Grid.construct()

	# Randomly disconnect neighboring tiles.
	for neighbor:Tile in tile.get_neighbors().values():
		if not neighbor: continue 
		if randi_range(0,1) == 0: continue
		neighbor.disconnected.emit()
		new_grid.add_tile(neighbor)

	tile.disconnected.emit()
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
	if not self: return
	if not is_instance_valid(self): return

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
	print(sections.size())

	return sections


func _recursive_tile_search(section:Array, origin_tile:Tile, passed_tiles:Array[Tile]) -> Dictionary:
	var tiles_to_check:Array[Tile] = [origin_tile]
	while not tiles_to_check.is_empty():
		var tile:Tile = tiles_to_check.pop_front()
		if not tile: continue
		if tile is not Tile: continue
		if not is_instance_valid(tile): continue
		if tile.is_queued_for_deletion(): continue
		if passed_tiles.has(tile): continue
		section.append(tile)
		passed_tiles.append(tile)
		for neighbor in tile.get_neighbors().values():
			tiles_to_check.append(neighbor)

	return {
		'new_section': section,
		'passed_tiles': passed_tiles,
	}


func _resolve_collision(body:Grid, tile:Tile) -> void:
	var velocity = (body.get_energy() - self.get_energy())
	var incoming_energy = abs(0.5 * (velocity))
	if tile.can_destroy.call(incoming_energy):
		self.destroy_tile.call_deferred(tile)
	elif tile.can_disconnect.call(incoming_energy):
		self.disconnect_tile.call_deferred(tile)


func _get_child_from_shape_idx(shape_index:int):
	var owner_id:int = self.shape_find_owner(shape_index)
	if owner_id not in self.get_shape_owners(): return null
	var owner = self.shape_owner_get_owner(owner_id)
	if owner is not Node: return null
	return owner


func _start_hovering_tile(tile:Tile) -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = SandboxManager.get_shader('tile_highlight')
	tile.get_texture_node().material = new_material


func _stop_hovering_tile(tile:Tile) -> void:
	tile.get_texture_node().material = null






# Callbacks.
# ----------
func _on_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int) -> void:
	if self.get_child_count()-1 < local_shape_index: return
	if self.get_child(local_shape_index) is not Tile: return
	var tile:Tile = self.get_child(local_shape_index)
	if body is Grid:
		_resolve_collision(body, tile)


func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	if event.is_action_pressed('right_click'):
		var node:Node = _get_child_from_shape_idx(shape_idx)
		if not node: return
		if node is not Tile: return
		self.destroy_tile(node)


func _on_mouse_shape_entered(shape_idx:int) -> void:
	var node:Node = _get_child_from_shape_idx(shape_idx)
	if not node: return
	if node is not Tile: return
	_start_hovering_tile(node)


func _on_mouse_shape_exited(shape_idx:int) -> void:
	var node:Node = _get_child_from_shape_idx(shape_idx)
	if not node: return
	if node is not Tile: return
	_stop_hovering_tile(node)
